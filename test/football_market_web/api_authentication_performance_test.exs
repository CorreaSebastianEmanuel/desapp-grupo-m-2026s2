defmodule FootballMarketWeb.APIAuthenticationPerformanceTest do
  use FootballMarket.DataCase, async: false

  @moduletag :integration
  use FootballMarket.AccountsCase

  import Plug.Conn
  import Plug.Test

  alias FootballMarketWeb.Plugs.AuthenticateAPI

  @moduletag :performance

  test "at least 38 of 40 complete decisions per method finish below one second" do
    assert {:ok, user} = Accounts.register_user(registration_attrs())

    assert {:ok, %{access_token: token}} =
             Accounts.login(%{email: user.email, password: "a secure password"})

    assert {:ok, key} = Accounts.issue_api_key(user.id)

    samples = [jwt: {"authorization", "Bearer " <> token}, api_key: {"x-api-key", key.secret}]

    Enum.each(samples, fn {method, header} ->
      for _ <- 1..5, do: decision(header)
      durations = for _ <- 1..40, do: timed_decision(header)
      below = Enum.count(durations, &(&1 < 1_000_000))
      p95 = durations |> Enum.sort() |> Enum.at(37)
      IO.puts("#{method}: #{below}/40 below 1s, p95=#{p95}us")
      assert below >= 38
    end)
  end

  defp timed_decision(header) do
    started = System.monotonic_time()
    decision(header)
    System.convert_time_unit(System.monotonic_time() - started, :native, :microsecond)
  end

  defp decision({name, value}) do
    result = conn(:get, "/") |> put_req_header(name, value) |> AuthenticateAPI.call([])
    assert result.assigns.authenticated_actor
  end
end
