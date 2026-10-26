defmodule FootballMarketWeb.RequestLogger do
  @moduledoc "HTTP logging context and safe lifecycle events, including early responses."
  @behaviour Plug
  require Logger
  alias FootballMarket.Observability.Context

  @impl true
  def init(options), do: options

  @impl true
  def call(conn, _) do
    request_id = conn.assigns.request_id
    context = [request_id: request_id, correlation_id: Context.id(request_id)]
    Context.put(context)

    Process.put(__MODULE__, %{
      context: context,
      method: conn.method,
      started_at: System.monotonic_time(),
      terminal: false
    })

    Plug.Conn.put_private(conn, :logging_context, context)
  end

  def handle_event([:phoenix, :endpoint, :start], _, %{conn: %Plug.Conn{} = conn}, _) do
    Logger.info("HTTP request started", event: "http.request.start", method: conn.method)
  end

  def handle_event([:phoenix, :endpoint, :stop], _, %{conn: %Plug.Conn{status: status} = conn}, _)
      when is_integer(status),
      do: finish(conn, conn.status, "http.request.stop")

  def handle_event(
        [:phoenix, :error_rendered],
        _,
        %{conn: %Plug.Conn{} = conn, status: status},
        _
      )
      when is_integer(status),
      do: finish(conn, status, "http.request.exception")

  def handle_event(_, _, _, _), do: :ok

  defp finish(conn, status, event) do
    case Process.get(__MODULE__) do
      %{terminal: false} = state ->
        Process.put(__MODULE__, %{state | terminal: true})
        log_finished(conn, status, event, state)

      _ ->
        :ok
    end
  end

  defp log_finished(conn, status, event, state) do
    Context.with_context(state.context, fn ->
      Logger.log(if(status >= 500, do: :error, else: :info), "HTTP request finished",
        event: event,
        method: state.method,
        route: route(conn),
        status: status,
        duration_ms:
          System.convert_time_unit(
            System.monotonic_time() - state.started_at,
            :native,
            :millisecond
          )
      )
    end)
  end

  defp route(%{private: %{phoenix_router: router}} = conn) do
    decoded = Enum.map(conn.path_info, &URI.decode/1)

    case Phoenix.Router.route_info(router, conn.method, decoded, conn.host) do
      %{route: route} -> route
      _ -> nil
    end
  end

  defp route(_), do: nil
end
