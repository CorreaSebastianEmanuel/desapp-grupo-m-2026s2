defmodule FootballMarket.Providers.FootballData.MintTransport do
  @moduledoc "One worker owns verified HTTP/1 sockets, with no redirects or retries."
  @behaviour FootballMarket.Providers.FootballData.Transport
  alias FootballMarket.Providers.FootballData.{Transport, Configuration}

  def request(route, credential, context, state) do
    try do
      true = Configuration.valid_transport?({__MODULE__, state})
      path = Transport.path(route)
      true = is_binary(credential) and not Regex.match?(~r/[\r\n]/, credential)
      {address, port, tls} = destination(state)

      case Mint.HTTP.connect(:https, address, port,
             protocols: [:http1],
             mode: :passive,
             hostname: if(state == :live, do: "api.football-data.org", else: "localhost"),
             transport_opts: Keyword.put(tls, :timeout, remaining(context))
           ) do
        {:ok, connection} ->
          try do
            remaining(context)

            case Mint.HTTP.request(connection, "GET", path, [{"x-auth-token", credential}], nil) do
              {:ok, sent, ref} ->
                read(sent, ref, context, %{
                  status: nil,
                  headers: [],
                  body: "",
                  headers_seen: false
                })

              _ ->
                {:error, :unavailable}
            end
          after
            Mint.HTTP.close(connection)
          end

        _ ->
          {:error, :unavailable}
      end
    rescue
      _ -> {:error, :unavailable}
    catch
      :deadline -> {:error, :timeout}
      _, _ -> {:error, :unavailable}
    end
  end

  defp destination(:live),
    do: {"api.football-data.org", 443, [verify: :verify_peer, cacerts: :public_key.cacerts_get()]}

  defp destination(state),
    do:
      {state.address, state.port,
       [
         verify: :verify_peer,
         cacertfile: String.to_charlist(state.cacertfile),
         server_name_indication: String.to_charlist(state.hostname),
         customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
       ]}

  defp read(conn, ref, context, acc) do
    case Mint.HTTP.recv(conn, 0, remaining(context)) do
      {:ok, conn, events} ->
        events(conn, ref, context, acc, events)

      {:error, conn, %Mint.TransportError{reason: :timeout}, []} ->
        {runtime, state} = context.runtime

        if runtime.now_us(state) < context.deadline_us do
          read(conn, ref, context, acc)
        else
          throw(:deadline)
        end

      {:error, conn, _reason, events} ->
        observed = accumulate(acc, ref, events, context)
        Mint.HTTP.close(conn)

        cond do
          is_integer(observed.status) and observed.status != 200 ->
            {:ok,
             Map.take(%{observed | body: ""}, [
               :status,
               :headers,
               :body,
               :received_us,
               :received_utc
             ])}

          observed.status == 200 ->
            {:error, :invalid_response}

          true ->
            {:error, :unavailable}
        end
    end
  end

  defp events(conn, ref, context, acc, events) do
    observed = accumulate(acc, ref, events, context)

    cond do
      is_integer(observed.status) and observed.status != 200 and observed.headers_seen ->
        Mint.HTTP.close(conn)

        {:ok,
         Map.take(%{observed | body: ""}, [:status, :headers, :body, :received_us, :received_utc])}

      Enum.any?(events, &(&1 == {:done, ref})) ->
        Mint.HTTP.close(conn)
        {:ok, Map.take(observed, [:status, :headers, :body, :received_us, :received_utc])}

      true ->
        read(conn, ref, context, observed)
    end
  end

  defp accumulate(acc, ref, events, context) do
    Enum.reduce(events, acc, fn
      {:status, ^ref, status}, a ->
        %{a | status: status}

      {:headers, ^ref, headers}, a ->
        observed = %{a | headers: a.headers ++ headers, headers_seen: true}

        if is_integer(a.status) and a.status != 200 and not a.headers_seen do
          {runtime, state} = context.runtime
          received = runtime.now_us(state)
          Map.merge(observed, %{received_us: received, received_utc: runtime.utc_now(state)})
        else
          observed
        end

      {:data, ^ref, bytes}, a ->
        %{a | body: a.body <> bytes}

      _, a ->
        a
    end)
  end

  defp remaining(context) do
    {runtime, state} = context.runtime
    remaining = context.deadline_us - runtime.now_us(state)
    if remaining <= 0, do: throw(:deadline)
    min(div(remaining + 999, 1000), 4_294_967_294)
  end
end
