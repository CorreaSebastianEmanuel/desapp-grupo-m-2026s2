defmodule FootballMarketWeb.Telemetry do
  @moduledoc "Phoenix, Ecto, and BEAM VM telemetry metrics supervisor."
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg), do: Supervisor.start_link(__MODULE__, arg, name: __MODULE__)

  @impl true
  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: [], period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      summary("phoenix.endpoint.start.system_time", unit: {:native, :millisecond}),
      summary("phoenix.endpoint.stop.duration", unit: {:native, :millisecond}),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("football_market.repo.query.total_time", unit: {:native, :millisecond}),
      counter("football_market.ranking.cache.hit.count",
        event_name: [:football_market, :ranking, :cache, :hit],
        measurement: :count
      ),
      counter("football_market.ranking.cache.miss.count",
        event_name: [:football_market, :ranking, :cache, :miss],
        measurement: :count
      ),
      counter("football_market.ranking.cache.error.count",
        event_name: [:football_market, :ranking, :cache, :error],
        measurement: :count
      ),
      summary("vm.memory.total", unit: {:byte, :kilobyte})
    ]
  end
end

defmodule FootballMarketWeb.RequestLogger do
  @moduledoc "Attaches HTTP correlation IDs and logs safe structured request start/stop events."
  @behaviour Plug
  require Logger
  alias FootballMarket.Observability

  @impl true
  def init(options), do: options

  @impl true
  def call(conn, _) do
    request_id = conn.assigns.request_id
    context = [request_id: request_id, correlation_id: Observability.id(request_id)]
    Observability.put(context)

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
    Observability.with_context(state.context, fn ->
      Logger.log(if(status >= 500, do: :error, else: :info), "HTTP request finished",
        event: event,
        method: state.method,
        route: route(conn),
        status: status,
        actor_id: actor_id(conn),
        parameters: safe_parameters(conn),
        duration_ms:
          System.convert_time_unit(
            System.monotonic_time() - state.started_at,
            :native,
            :millisecond
          )
      )
    end)
  end

  defp actor_id(conn) do
    actor = conn.assigns[:authenticated_actor] || conn.assigns[:browser_actor]
    if(actor, do: actor.account_id, else: conn.assigns[:audit_account_id]) || "anonymous"
  end

  defp safe_parameters(conn) do
    [conn.query_params, conn.body_params, conn.path_params]
    |> Enum.reject(&is_struct/1)
    |> Enum.reduce(%{}, &Map.merge(&2, &1))
    |> Enum.filter(fn {key, value} -> safe_parameter?(key, value) end)
    |> Map.new()
  end

  defp safe_parameter?(key, value)
       when key in ~w(id player_id league_id team_id position_id) and is_binary(value) and
              byte_size(value) == 36,
       do: match?({:ok, _}, Ecto.UUID.cast(value))

  defp safe_parameter?(key, value) when key in ~w(quantity page_size) do
    (is_integer(value) and value >= 0 and value < 100_000_000_000_000_000_000) or
      (is_binary(value) and byte_size(value) <= 20 and Regex.match?(~r/\A[0-9]+\z/, value))
  end

  defp safe_parameter?("maximum_unit_price", value) when is_binary(value),
    do: byte_size(value) <= 40 and Regex.match?(~r/\A[0-9]+(?:\.[0-9]+)?\z/, value)

  defp safe_parameter?(key, value) when key in ~w(date from to) and is_binary(value),
    do: match?({:ok, _}, Date.from_iso8601(value))

  defp safe_parameter?("expires_at", value) when is_binary(value),
    do: byte_size(value) <= 40 and match?({:ok, _, _}, DateTime.from_iso8601(value))

  defp safe_parameter?(_, _), do: false

  defp route(%{private: %{phoenix_router: router}} = conn) do
    decoded = Enum.map(conn.path_info, &URI.decode/1)

    case Phoenix.Router.route_info(router, conn.method, decoded, conn.host) do
      %{route: route} -> route
      _ -> "unmatched"
    end
  end

  defp route(_), do: "unmatched"
end
