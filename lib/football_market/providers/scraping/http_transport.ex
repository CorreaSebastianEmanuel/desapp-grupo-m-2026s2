defmodule FootballMarket.Providers.Scraping.HttpTransport do
  @moduledoc "Assessed HTTPS document transport with bounded streaming and no retries."
  @behaviour FootballMarket.Providers.Scraping.Transport
  alias FootballMarket.Providers.Scraping.{Assessment, Budget}

  @max_document_bytes 2_000_000

  def acquire(request, context, state) do
    with {:ok, assessment, _, _} <- Assessment.admit_snapshot(request, state),
         {:ok, table} <- admission_table(state),
         {:ok, lease} <-
           Budget.acquire(
             request,
             context,
             Map.put(state, :admission, table),
             not is_nil(assessment.limits[:window_ms])
           ) do
      case reserve_volume(assessment.limits) do
        :ok ->
          {:ok, lease}

        error ->
          Budget.release(lease, state)
          error
      end
    end
  end

  @volume_key "fotmob-public-player-imports"
  defp reserve_volume(%{window_ms: window, volume: limit}) do
    case FootballMarket.Providers.RateLimit.reserve_volume(@volume_key, limit, window) do
      :ok -> :ok
      {:defer, wait} -> {:error, %{category: :rate_limited, retry_after_ms: wait}}
      _ -> {:error, %{category: :unavailable}}
    end
  rescue
    _ -> {:error, %{category: :unavailable}}
  end

  defp reserve_volume(_), do: :ok

  def release(lease, state), do: Budget.release(lease, state)

  def fetch(key, context, state) do
    with :ok <- before_deadline(context),
         {:ok, assessment, revision, row} <-
           Assessment.admit_snapshot(state[:request], state, state[:assessment_revision]),
         {:ok, uri, destination} <- endpoint(key, row, assessment, state),
         {:ok, status, headers, body} <- request(uri, context, state),
         :ok <- before_deadline(context),
         :ok <- status(status, headers, context, assessment),
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
        {:ok, Budget.table()}
    end
  rescue
    _ -> {:error, %{category: :rate_limited}}
  end

  defp endpoint(key, row, assessment, state) do
    documents = row[:documents] || %{}

    case Map.get(documents, key) || dynamic_endpoint(key, documents, state) do
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

  defp dynamic_endpoint("player_data:" <> player_id, documents, _state) do
    player_page(documents["player_page"], player_id)
  end

  defp dynamic_endpoint("player_search:" <> player_name, documents, _state) do
    player_search(documents["player_search"], player_name)
  end

  defp dynamic_endpoint("match_details:" <> match_id, documents, state) do
    path = Map.get(state[:match_page_urls] || %{}, match_id)

    case documents["match_details"] do
      nil -> match_page(path)
      base -> exact_match_resource(base, path, match_id)
    end
  end

  defp dynamic_endpoint(_, _, _), do: nil

  defp player_page(base, player_id) when is_binary(base) do
    if FootballMarket.Providers.Provenance.safe_text?(player_id) do
      uri = URI.parse(base)

      if uri.path in [nil, "", "/players", "/players/"] and is_nil(uri.query) and
           is_nil(uri.fragment) do
        %{uri | path: "/players/" <> player_id} |> URI.to_string()
      end
    end
  end

  defp player_page(_, _), do: nil

  defp player_search(base, player_name) when is_binary(base) and is_binary(player_name) do
    uri = URI.parse(base)

    if uri.scheme == "https" and uri.host == "www.fotmob.com" and
         uri.path == "/api/data/search/suggest" and is_nil(uri.userinfo) and
         is_nil(uri.query) and is_nil(uri.fragment) and
         FootballMarket.Providers.Provenance.safe_text?(player_name) do
      query = URI.encode_query(%{"hits" => "50", "lang" => "en,es", "term" => player_name})
      %{uri | query: query} |> URI.to_string()
    end
  end

  defp player_search(_, _), do: nil

  defp match_page(path) when is_binary(path) do
    uri = URI.parse(path)
    segments = String.split(uri.path || "", "/", trim: true) |> Enum.map(&URI.decode/1)

    if length(segments) >= 2 and hd(segments) == "matches" and
         Enum.all?(segments, &(&1 not in [".", "..", "api"])) and is_nil(uri.scheme) and
         is_nil(uri.host) and is_nil(uri.userinfo) and is_nil(uri.query) do
      URI.merge("https://www.fotmob.com", %{uri | fragment: nil}) |> URI.to_string()
    end
  end

  defp match_page(_), do: nil

  defp exact_match_resource(base, path, match_id)
       when is_binary(base) and is_binary(path) and is_binary(match_id) do
    uri = URI.parse(base)
    profile_uri = URI.parse(path)

    if exact_match_base?(uri) and
         not is_nil(match_page(path)) and profile_uri.fragment in [nil, match_id] and
         Regex.match?(~r/\A[0-9]{1,16}\z/, match_id) do
      %{uri | query: URI.encode_query(%{"matchId" => match_id})} |> URI.to_string()
    end
  end

  defp exact_match_resource(_, _, _), do: nil

  defp exact_match_base?(%URI{
         scheme: "https",
         host: "www.fotmob.com",
         port: port,
         path: "/api/data/matchDetails",
         userinfo: nil,
         query: nil,
         fragment: nil
       })
       when port in [nil, 443], do: true

  defp exact_match_base?(_), do: false

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

    request_headers = [
      {~c"accept", ~c"application/json"},
      {~c"user-agent", ~c"FootballMarket/0.1 (educational statistics importer)"}
    ]

    request_options = [
      sync: false,
      receiver: self(),
      stream: {:self, :once},
      max_header_size: 16_384,
      max_body_size: @max_document_bytes
    ]

    case :httpc.request(
           :get,
           {String.to_charlist(url), request_headers},
           http_options,
           request_options
         ) do
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
          do: {:ok, 206, headers, IO.iodata_to_binary(Enum.reverse(chunks))},
          else: {:ok, 200, headers, IO.iodata_to_binary(Enum.reverse(chunks))}

      {:error, %{category: _} = failure} ->
        cancel_request(request_id, state)
        {:error, failure}

      {:complete, status, headers, body} when is_integer(status) and is_binary(body) ->
        if byte_size(body) <= @max_document_bytes do
          {:ok, status, headers, body}
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

        {:http, {^request_id, {_version, status, _reason}, headers, body}}
        when is_integer(status) and is_binary(body) ->
          {:complete, status, headers, body}

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

  defp status(200, _, _, _), do: :ok

  defp status(code, _, _, _) when code in [401, 403],
    do: {:error, %{category: :authentication_failed}}

  defp status(429, headers, context, assessment) do
    delay = max(retry_after(headers, context) || 60_000, 1)

    if assessment.limits[:window_ms],
      do: FootballMarket.Providers.RateLimit.block(@volume_key, delay)

    {:error, %{category: :rate_limited, retry_after_ms: delay}}
  end

  defp status(code, _, _, _) when code in 500..599, do: {:error, %{category: :unavailable}}
  defp status(_, _, _, _), do: {:error, %{category: :invalid_response}}

  defp retry_after(headers, context) do
    value =
      Enum.find_value(headers, fn {key, value} ->
        if String.downcase(to_string(key)) == "retry-after", do: to_string(value)
      end)

    case value && Integer.parse(value) do
      {seconds, ""} when seconds >= 0 ->
        seconds * 1000

      _ ->
        with value when is_binary(value) <- value,
             {{_, _, _}, {_, _, _}} = date <-
               :httpd_util.convert_request_date(String.to_charlist(value)),
             {:ok, date} <- NaiveDateTime.from_erl(date) do
          {runtime, clock} = context.runtime

          max(
            NaiveDateTime.diff(date, DateTime.to_naive(runtime.utc_now(clock)), :millisecond),
            0
          )
        else
          _ -> nil
        end
    end
  rescue
    _ -> nil
  end

  defp before_deadline(context) do
    {runtime, runtime_state} = context.runtime

    if runtime.now_us(runtime_state) < context.deadline_us,
      do: :ok,
      else: {:error, %{category: :timeout}}
  end
end
