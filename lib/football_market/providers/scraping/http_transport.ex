defmodule FootballMarket.Providers.Scraping.HttpTransport do
  @moduledoc "Assessed HTTPS document transport with bounded streaming and no retries."
  @behaviour FootballMarket.Providers.Scraping.Transport
  alias FootballMarket.Providers.Scraping.{Admission, Assessment, FixtureTransport}

  @max_document_bytes 2_000_000

  def acquire(request, context, state) do
    with {:ok, _, _} <- Assessment.admit(request, state),
         {:ok, table} <- admission_table(state) do
      FixtureTransport.acquire(request, context, Map.put(state, :admission, table))
    end
  end

  def release(lease, state), do: FixtureTransport.release(lease, state)

  def fetch(key, context, state) do
    with :ok <- before_deadline(context),
         {:ok, assessment, revision, row} <-
           Assessment.admit_snapshot(state[:request], state, state[:assessment_revision]),
         {:ok, uri, destination} <- endpoint(key, row, assessment),
         {:ok, status, body} <- request(uri, context, state),
         :ok <- before_deadline(context),
         :ok <- status(status),
         true <- is_binary(body) and byte_size(body) <= @max_document_bytes do
      {:ok,
       %{
         body: body,
         observation: %{
           terminal: true,
           witness: row.witness,
           destination: destination,
           assessment_revision: revision
         }
       }}
    else
      {:error, %{category: _} = failure} -> {:error, failure}
      _ -> {:error, %{category: :invalid_response}}
    end
  rescue
    _ -> {:error, %{category: :unavailable}}
  catch
    _, _ -> {:error, %{category: :unavailable}}
  end

  defp admission_table(state) do
    cond do
      Map.has_key?(state, :admission) and is_nil(state.admission) ->
        {:error, %{category: :rate_limited}}

      Map.has_key?(state, :admission) ->
        if :ets.info(state.admission) == :undefined,
          do: {:error, %{category: :rate_limited}},
          else: {:ok, state.admission}

      true ->
        {:ok, Admission.table()}
    end
  rescue
    _ -> {:error, %{category: :rate_limited}}
  end

  defp endpoint(key, row, assessment) do
    case Map.get(row[:documents] || %{}, key) do
      url when is_binary(url) ->
        uri = URI.parse(url)
        destination = origin(uri)

        if safe_uri?(uri) and destination in assessment.destinations,
          do: {:ok, uri, destination},
          else: {:error, %{category: :unsupported_capability}}

      _ ->
        {:error, %{category: :unsupported_capability}}
    end
  end

  defp safe_uri?(%URI{scheme: "https", host: host, userinfo: nil, fragment: nil}),
    do: is_binary(host) and host != ""

  defp safe_uri?(_), do: false

  defp origin(%URI{scheme: "https", host: host, port: port}) when port in [nil, 443],
    do: "https://" <> String.downcase(host)

  defp origin(%URI{scheme: "https", host: host, port: port}) when is_integer(port),
    do: "https://" <> String.downcase(host) <> ":" <> Integer.to_string(port)

  defp origin(_), do: nil

  defp request(uri, context, state) do
    parent = self()
    reply = make_ref()

    {helper, monitor} =
      spawn_monitor(fn ->
        stream_request(parent, reply, URI.to_string(uri), context, state)
      end)

    receive do
      {^reply, result} ->
        Process.demonitor(monitor, [:flush])
        result

      {:DOWN, ^monitor, :process, ^helper, _reason} ->
        {:error, %{category: :unavailable}}
    end
  end

  defp stream_request(parent, reply, url, context, state) do
    parent_monitor = Process.monitor(parent)

    result =
      if Process.alive?(parent) do
        case start_request(url, context, state) do
          {:ok, request_id} ->
            collect_response(request_id, nil, [], 0, parent, parent_monitor, context, state)

          {:error, failure} ->
            {:error, failure}
        end
      else
        {:error, %{category: :timeout}}
      end

    Process.demonitor(parent_monitor, [:flush])
    send(parent, {reply, result})
  end

  defp start_request(url, context, state) do
    {runtime, runtime_state} = context.runtime
    timeout = max(1, div(context.deadline_us - runtime.now_us(runtime_state), 1000))

    case state[:http_start] do
      fun when is_function(fun, 3) ->
        normalize_start(fun.(url, timeout, self()))

      _ ->
        httpc_start(url, timeout)
    end
  rescue
    _ -> {:error, %{category: :unavailable}}
  end

  defp normalize_start({:ok, request_id}), do: {:ok, request_id}
  defp normalize_start({:error, %{category: _} = failure}), do: {:error, failure}
  defp normalize_start({:error, _}), do: {:error, %{category: :unavailable}}
  defp normalize_start(_), do: {:error, %{category: :invalid_response}}

  defp httpc_start(url, timeout) do
    _ = Application.ensure_all_started(:inets)
    _ = Application.ensure_all_started(:ssl)

    http_options = [
      timeout: timeout,
      connect_timeout: timeout,
      autoredirect: false,
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]

    request_options = [
      sync: false,
      receiver: self(),
      stream: {:self, :once},
      max_header_size: 16_384,
      max_body_size: @max_document_bytes
    ]

    case :httpc.request(:get, {String.to_charlist(url), []}, http_options, request_options) do
      {:ok, request_id} -> {:ok, request_id}
      {:error, _} -> {:error, %{category: :unavailable}}
    end
  end

  defp collect_response(request_id, handler, chunks, size, parent, parent_monitor, context, state) do
    execution = %{parent: parent, parent_monitor: parent_monitor, context: context, state: state}

    case await_response(request_id, parent, parent_monitor, context, state) do
      {:stream_start, headers, stream_handler} ->
        collect_stream_start(request_id, headers, stream_handler, chunks, size, execution)

      {:stream_chunk, chunk} when is_binary(chunk) ->
        collect_stream_chunk(request_id, handler, chunk, chunks, size, execution)

      {:stream_end, headers} ->
        if content_range?(headers),
          do: {:ok, 206, IO.iodata_to_binary(Enum.reverse(chunks))},
          else: {:ok, 200, IO.iodata_to_binary(Enum.reverse(chunks))}

      {:error, %{category: _} = failure} ->
        cancel_request(request_id, state)
        {:error, failure}

      {:complete, status, body} when is_integer(status) and is_binary(body) ->
        if byte_size(body) <= @max_document_bytes do
          {:ok, status, body}
        else
          cancel_request(request_id, state)
          {:error, %{category: :invalid_response}}
        end
    end
  end

  defp await_response(request_id, parent, parent_monitor, context, state) do
    {runtime, runtime_state} = context.runtime
    remaining = context.deadline_us - runtime.now_us(runtime_state)

    if remaining <= 0 do
      {:error, %{category: :timeout}}
    else
      receive do
        {:DOWN, ^parent_monitor, :process, ^parent, _reason} ->
          cancel_request(request_id, state)
          {:error, %{category: :timeout}}

        {:http, {^request_id, :stream_start, headers, handler}} ->
          {:stream_start, headers, handler}

        {:http, {^request_id, :stream, chunk}} ->
          {:stream_chunk, chunk}

        {:http, {^request_id, :stream_end, headers}} ->
          {:stream_end, headers}

        {:http, {^request_id, {_version, status, _reason}, _headers, body}}
        when is_integer(status) and is_binary(body) ->
          {:complete, status, body}

        {:http, {^request_id, {:error, reason}}} ->
          {:error, http_error(reason)}
      after
        max(1, div(remaining + 999, 1000)) -> {:error, %{category: :timeout}}
      end
    end
  end

  defp collect_stream_start(request_id, headers, handler, chunks, size, execution) do
    %{parent: parent, parent_monitor: parent_monitor, context: context, state: state} = execution

    with {:ok, declared} <- declared_size(headers),
         true <- declared == :unknown or declared <= @max_document_bytes do
      next_stream(handler, state)
      collect_response(request_id, handler, chunks, size, parent, parent_monitor, context, state)
    else
      _ ->
        cancel_request(request_id, state)
        {:error, %{category: :invalid_response}}
    end
  end

  defp collect_stream_chunk(request_id, handler, chunk, chunks, size, execution) do
    %{parent: parent, parent_monitor: parent_monitor, context: context, state: state} = execution

    next_size = size + byte_size(chunk)

    if next_size <= @max_document_bytes do
      next_stream(handler, state)

      collect_response(
        request_id,
        handler,
        [chunk | chunks],
        next_size,
        parent,
        parent_monitor,
        context,
        state
      )
    else
      cancel_request(request_id, state)
      {:error, %{category: :invalid_response}}
    end
  end

  defp declared_size(headers) do
    case header(headers, "content-length") do
      nil ->
        {:ok, :unknown}

      value ->
        case Integer.parse(value) do
          {size, ""} when size >= 0 -> {:ok, size}
          _ -> {:error, %{category: :invalid_response}}
        end
    end
  end

  defp content_range?(headers), do: not is_nil(header(headers, "content-range"))

  defp header(headers, name) do
    Enum.find_value(headers, fn {key, value} ->
      if String.downcase(to_string(key)) == name, do: to_string(value)
    end)
  end

  defp next_stream(handler, state) do
    case state[:http_stream_next] do
      fun when is_function(fun, 1) -> fun.(handler)
      _ -> :httpc.stream_next(handler)
    end
  end

  defp cancel_request(request_id, state) do
    case state[:http_cancel] do
      fun when is_function(fun, 1) -> fun.(request_id)
      _ -> :httpc.cancel_request(request_id)
    end
  rescue
    _ -> :ok
  end

  defp http_error(reason) when reason in [:timeout, :body_too_big],
    do: %{category: if(reason == :timeout, do: :timeout, else: :invalid_response)}

  defp http_error(_), do: %{category: :unavailable}

  defp status(200), do: :ok
  defp status(429), do: {:error, %{category: :rate_limited}}
  defp status(code) when code in 500..599, do: {:error, %{category: :unavailable}}
  defp status(_), do: {:error, %{category: :invalid_response}}

  defp before_deadline(context) do
    {runtime, runtime_state} = context.runtime

    if runtime.now_us(runtime_state) < context.deadline_us,
      do: :ok,
      else: {:error, %{category: :timeout}}
  end
end
