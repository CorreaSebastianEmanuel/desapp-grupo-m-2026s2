defmodule FootballMarketWeb.APIAuthenticationProbe.Validator do
  @moduledoc false

  def validate_access_token(value), do: invoke(:jwt, value)
  def identify_api_key(value), do: invoke(:api_key, value)

  defp invoke(method, value) do
    if pid = Process.get({__MODULE__, :owner}), do: send(pid, {:validator_called, method, value})

    case Process.get({__MODULE__, method}) do
      fun when is_function(fun, 1) -> fun.(value)
      result when not is_nil(result) -> result
      _ -> {:error, :invalid}
    end
  end
end

defmodule FootballMarketWeb.APIAuthenticationProbe do
  @moduledoc false
  import Plug.Conn

  def init(action), do: action

  def call(conn, action) do
    if pid = Process.get({__MODULE__, :owner}),
      do: send(pid, {:probe_called, action, conn.assigns})

    send_resp(conn, 200, "ok")
  end
end

defmodule FootballMarketWeb.APIAuthenticationProbe.Router do
  @moduledoc false
  use Phoenix.Router

  pipeline :api_public do
    plug :accepts, ["json"]
  end

  pipeline :api_protected do
    plug :accepts, ["json"]

    plug FootballMarketWeb.Plugs.AuthenticateAPI,
      validator: FootballMarketWeb.APIAuthenticationProbe.Validator
  end

  scope "/api" do
    pipe_through :api_public
    get "/public", FootballMarketWeb.APIAuthenticationProbe, :public
  end

  scope "/api" do
    pipe_through :api_protected
    get "/protected", FootballMarketWeb.APIAuthenticationProbe, :protected
  end
end
