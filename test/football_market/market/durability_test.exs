defmodule FootballMarket.Market.DurabilityTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.MarketCase
  alias FootballMarket.{Market, Repo}

  test "committed evidence survives owned Repo reconnect and fresh BEAM without provider state" do
    f = Map.merge(private_schema(), fixture())
    assert {:ok, %{issuance: e}} = Market.initialize_player(f.player.id)
    Supervisor.stop(f.repo)
    {:ok, replacement} = client(f.schema)
    Repo.put_dynamic_repo(replacement)
    on_exit(fn -> if Process.alive?(replacement), do: Supervisor.stop(replacement) end)
    assert {:ok, ^e} = Market.get_initial_issuance(f.player.id)

    fresh(f.schema, """
    Application.put_env(:football_market, :initial_issuance_recipients, [#{inspect(f.owner.id)}])
    Application.put_env(:football_market, FootballMarket.Providers, provider: nil, positions: nil)
    assert {:ok, e} = Market.get_initial_issuance(#{inspect(f.player.id)})
    assert e.id == #{inspect(e.id)}
    assert e.initial_quote_id == #{inspect(e.initial_quote_id)}
    assert e.recipient_id == #{inspect(f.owner.id)}
    assert e.quantity === 100
    assert Decimal.equal?(e.initial_unit_price, Decimal.new(1))
    assert Decimal.equal?(e.initial_inventory_value, Decimal.new(100))
    assert e.rule_id == "initial_issuance" and e.rule_version == "1"
    assert DateTime.to_iso8601(e.completed_at) == #{inspect(DateTime.to_iso8601(e.completed_at))}
    assert e.effective_at == e.completed_at
    assert {:ok, %{outcome: :already_completed, issuance: ^e}} = Market.initialize_player(e.player_id)
    assert Repo.query!("SELECT count(*) FROM market_issuances").rows == [[1]]
    """)
  end
end
