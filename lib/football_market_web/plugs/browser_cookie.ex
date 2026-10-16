defmodule FootballMarketWeb.Plugs.BrowserCookie do
  @moduledoc "Caps cookie retention at the immutable server deadline after session encoding."
  import Plug.Conn
  alias FootballMarket.Accounts.BrowserSessions
  def init(options), do: options

  def call(conn, _) do
    register_before_send(conn, fn conn ->
      with %{value: _} = cookie <- conn.resp_cookies["_football_market_key"],
           {:ok, actor} <- BrowserSessions.validate(get_session(conn, :browser_handle)) do
        # Max-Age is integral; round up so transport never ends authority early.
        # The database deadline remains the exclusive authorization boundary.
        remaining = DateTime.diff(actor.expires_at, BrowserSessions.now(), :microsecond)
        seconds = max(div(remaining + 999_999, 1_000_000), 0)

        %{
          conn
          | resp_cookies:
              Map.put(
                conn.resp_cookies,
                "_football_market_key",
                Map.put(cookie, :max_age, seconds)
              )
        }
      else
        _ -> conn
      end
    end)
  end
end
