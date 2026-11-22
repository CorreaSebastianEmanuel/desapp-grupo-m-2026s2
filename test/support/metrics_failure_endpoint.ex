defmodule FootballMarketWeb.LoggingFailureEndpoint do
  @moduledoc false
  use Plug.Builder, wrap_on_error: true

  use Phoenix.Endpoint.RenderErrors,
    formats: [json: FootballMarketWeb.ErrorJSON],
    layout: false

  plug Plug.RequestId, assign_as: :request_id
  plug FootballMarketWeb.RequestLogger
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint], log: false
  plug :endpoint
  plug :fail

  defp endpoint(conn, _),
    do: Plug.Conn.put_private(conn, :phoenix_endpoint, FootballMarketWeb.Endpoint)

  defp fail(_conn, _), do: raise("DO-NOT-LOG")
end
