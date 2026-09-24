defmodule FootballMarket.AuthenticationHelpers do
  @moduledoc false

  def fixed_time, do: Application.fetch_env!(:football_market, :authentication_test_time)
  def deterministic_jti, do: Application.fetch_env!(:football_market, :authentication_test_jti)

  def signed_token(claims, algorithm \\ "HS256", key \\ configured_key()) do
    {:ok, token, _claims} =
      Joken.generate_and_sign(%{}, claims, Joken.Signer.create(algorithm, key))

    token
  end

  def mutate_signature(token) do
    [header, payload, signature] = String.split(token, ".", parts: 3)
    replacement = if String.ends_with?(signature, "A"), do: "B", else: "A"

    header <>
      "." <> payload <> "." <> String.slice(signature, 0, byte_size(signature) - 1) <> replacement
  end

  def put_fixed_authentication(time, jti \\ Ecto.UUID.generate()) do
    previous = Application.fetch_env!(:football_market, FootballMarket.Accounts.Authentication)
    Application.put_env(:football_market, :authentication_test_time, time)
    Application.put_env(:football_market, :authentication_test_jti, jti)

    Application.put_env(
      :football_market,
      FootballMarket.Accounts.Authentication,
      Keyword.merge(previous,
        clock: {__MODULE__, :fixed_time, []},
        jti_provider: {__MODULE__, :deterministic_jti, []}
      )
    )

    ExUnit.Callbacks.on_exit(fn ->
      Application.put_env(:football_market, FootballMarket.Accounts.Authentication, previous)
      Application.delete_env(:football_market, :authentication_test_time)
      Application.delete_env(:football_market, :authentication_test_jti)
    end)

    jti
  end

  defp configured_key do
    config = Application.fetch_env!(:football_market, FootballMarket.Accounts.Authentication)
    {:ok, key} = Base.decode64(config[:signing_key])
    key
  end
end
