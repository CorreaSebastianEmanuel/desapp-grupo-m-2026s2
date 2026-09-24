defmodule FootballMarket.Accounts.AuthenticationPerformanceTest do
  use FootballMarket.DataCase, async: false
  use FootballMarket.AccountsCase

  @moduletag :performance

  test "warm login and standalone validation report nearest-rank p95" do
    password = "benchmark secure password"

    {:ok, user} =
      Accounts.register_user(%{email: "jwt-benchmark@example.test", password: password})

    credentials = %{email: user.email, password: password}

    for _ <- 1..10, do: assert({:ok, _} = Accounts.login(credentials))

    login_samples =
      for _ <- 1..100 do
        {micros, {:ok, %{access_token: token}}} = timed(fn -> Accounts.login(credentials) end)
        {micros, token}
      end

    token = login_samples |> List.last() |> elem(1)

    validation_samples =
      for _ <- 1..1_000, do: timed(fn -> Accounts.validate_access_token(token) end) |> elem(0)

    login_p95 = login_samples |> Enum.map(&elem(&1, 0)) |> nearest_rank_p95()
    validation_p95 = nearest_rank_p95(validation_samples)

    IO.puts(
      "JWT benchmark: login_p95_us=#{login_p95} validation_p95_us=#{validation_p95} " <>
        "os=#{inspect(:os.type())} otp=#{System.otp_release()} schedulers=#{System.schedulers_online()} " <>
        "argon2=t1,m8,p1 samples=100/1000 warmups=10"
    )

    assert login_p95 < 1_000_000
    assert validation_p95 < 1_000_000
  end

  defp timed(operation) do
    started = System.monotonic_time(:microsecond)
    result = operation.()
    {System.monotonic_time(:microsecond) - started, result}
  end

  defp nearest_rank_p95(samples) do
    sorted = Enum.sort(samples)
    Enum.at(sorted, ceil(length(sorted) * 0.95) - 1)
  end
end
