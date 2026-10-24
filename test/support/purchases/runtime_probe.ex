defmodule FootballMarket.Purchases.RuntimeProbe do
  @moduledoc false
  def queued(f, calls, table \\ "players") do
    import ExUnit.Assertions
    alias FootballMarket.{Repo, MarketCase}
    owner = self()
    ref = make_ref()

    {:ok, tasks} =
      Repo.transaction(fn ->
        Repo.query!("SELECT id FROM #{table} FOR UPDATE")

        for call <- calls do
          task = contender(f.schema, owner, ref, call)
          process = task.pid
          assert_receive {^ref, ^process, backend}, 10_000
          send(process, {ref, :go})
          MarketCase.blocked(backend)
          task
        end
      end)

    Enum.map(tasks, &Task.await(&1, 20_000))
  end

  defp contender(schema, owner, ref, call) do
    Task.async(fn ->
      FootballMarket.MarketCase.in_client(schema, fn -> checked(owner, ref, call) end)
    end)
  end

  defp checked(owner, ref, call) do
    FootballMarket.Repo.checkout(fn ->
      FootballMarket.MarketCase.barrier(owner, ref, FootballMarket.MarketCase.backend())
      call.()
    end)
  end

  defdelegate owned_store!(), to: FootballMarket.Quotes.RuntimeProbe
  defdelegate destroy_store!(store), to: FootballMarket.Quotes.RuntimeProbe
  defdelegate fresh_beam!(code, env \\ []), to: FootballMarket.Quotes.RuntimeProbe
  defdelegate await(assertion, timeout \\ 5_000), to: FootballMarket.Quotes.RuntimeProbe
end
