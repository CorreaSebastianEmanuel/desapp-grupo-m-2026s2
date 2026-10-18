defmodule FootballMarket.Quotes.ConcurrencyTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.Quotes
  alias FootballMarket.QuotesCase
  alias FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations

  setup do
    namespace = ValuationConfigurationCase.private_schema()
    {:ok, Map.put(QuotesCase.fixture(), :namespace, namespace)}
  end

  test "concurrent identical requests commit one quote and one evaluation", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    request_ids = Enum.map(1..2, fn _ -> Ecto.UUID.generate() end)

    results =
      1..2
      |> Task.async_stream(
        fn index ->
          ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
            Quotes.request(f.subject, :active, f.mapping.id, Enum.at(request_ids, index - 1))
          end)
        end,
        max_concurrency: 2,
        timeout: 20_000,
        ordered: true
      )
      |> Enum.map(fn {:ok, result} -> result end)

    assert [{:ok, first}, {:ok, second}] = results
    assert first.calculation.id == second.calculation.id

    ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
      assert {:ok, history} = Quotes.list_history(f.player.id)
      assert Enum.count(history, &(&1.calculation_id == first.calculation.id)) == 1
      assert {:ok, [event]} = Quotes.pending_evaluations()
      assert event.calculation_id == first.calculation.id
    end)
  end
end
