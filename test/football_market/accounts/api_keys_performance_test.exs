defmodule FootballMarket.Accounts.ApiKeysPerformanceTest do
  use FootballMarket.DataCase
  use FootballMarket.AccountsCase

  @moduletag :performance

  test "40 issuance and identification calls meet the local one-second sample" do
    {:ok, user} = Accounts.register_user(registration_attrs())
    {:ok, warm_key} = Accounts.issue_api_key(user.id)
    assert {:ok, _} = Accounts.identify_api_key(warm_key.secret)

    issued =
      for _ <- 1..40 do
        {micros, {:ok, key}} = timed(fn -> Accounts.issue_api_key(user.id) end)
        {micros, key}
      end

    identified =
      for {_issue_micros, key} <- issued do
        {micros, {:ok, _identity}} = timed(fn -> Accounts.identify_api_key(key.secret) end)
        micros
      end

    issue_count = Enum.count(issued, fn {micros, _} -> micros < 1_000_000 end)
    identify_count = Enum.count(identified, &(&1 < 1_000_000))
    IO.puts("API key timing: issue #{issue_count}/40, identify #{identify_count}/40 under 1s")
    assert issue_count >= 38
    assert identify_count >= 38
  end

  defp timed(operation) do
    started = System.monotonic_time(:microsecond)
    result = operation.()
    {System.monotonic_time(:microsecond) - started, result}
  end
end
