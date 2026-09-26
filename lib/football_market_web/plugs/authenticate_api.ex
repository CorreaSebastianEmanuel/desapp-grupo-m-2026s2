defmodule FootballMarketWeb.Plugs.AuthenticateAPI do
  @moduledoc "Authenticates exactly one supported API credential and assigns its actor."

  import Plug.Conn

  alias FootballMarket.Accounts
  alias FootballMarket.Accounts.AuthenticatedActor

  @event [:football_market, :api, :authentication]
  @challenge ~s(Bearer realm="api")
  @body Jason.encode!(%{error: %{code: "unauthenticated"}})

  def init(opts), do: opts

  def call(conn, opts) do
    started = System.monotonic_time()
    validator = Keyword.get(opts, :validator, Accounts)

    {conn, outcome, method} = authenticate(conn, validator)

    :telemetry.execute(
      @event,
      %{duration: System.monotonic_time() - started},
      %{route_policy: :protected, outcome: outcome, authentication_method: method}
    )

    conn
  end

  defp authenticate(conn, validator) do
    authorization = get_req_header(conn, "authorization")
    api_keys = get_req_header(conn, "x-api-key")

    case {authorization, api_keys} do
      {[value], []} when is_binary(value) -> authenticate_bearer(conn, value, validator)
      {[], [value]} when is_binary(value) -> authenticate_api_key(conn, value, validator)
      _ -> {reject(conn), :error, nil}
    end
  end

  defp authenticate_bearer(conn, value, validator) do
    with {:ok, token} <- bearer_token(value),
         {:ok, %{account_id: account_id, token_id: token_id}} <-
           safely_validate(fn -> validator.validate_access_token(token) end) do
      actor = %AuthenticatedActor{
        account_id: account_id,
        authentication_method: :jwt,
        credential_id: token_id
      }

      {assign(conn, :authenticated_actor, actor), :ok, :jwt}
    else
      _ -> {reject(conn), :error, :jwt}
    end
  end

  defp authenticate_api_key(conn, secret, validator) do
    case safely_validate(fn -> validator.identify_api_key(secret) end) do
      {:ok, %{account_id: account_id, key_id: key_id}} ->
        actor = %AuthenticatedActor{
          account_id: account_id,
          authentication_method: :api_key,
          credential_id: key_id
        }

        {assign(conn, :authenticated_actor, actor), :ok, :api_key}

      _ ->
        {reject(conn), :error, :api_key}
    end
  end

  # HTTP whitespace separates scheme and credential; token bytes are otherwise untouched.
  defp bearer_token(value) do
    case Regex.run(~r/\A(?i:bearer)[\t ]+([^\t ]+)\z/, value, capture: :all_but_first) do
      [token] -> {:ok, token}
      _ -> :error
    end
  end

  defp safely_validate(function) do
    function.()
  rescue
    _ -> {:error, :authentication_failed}
  catch
    _, _ -> {:error, :authentication_failed}
  end

  defp reject(conn) do
    %{conn | assigns: Map.delete(conn.assigns, :authenticated_actor)}
    |> put_resp_header("www-authenticate", @challenge)
    |> put_resp_content_type("application/json")
    |> send_resp(401, @body)
    |> halt()
  end
end
