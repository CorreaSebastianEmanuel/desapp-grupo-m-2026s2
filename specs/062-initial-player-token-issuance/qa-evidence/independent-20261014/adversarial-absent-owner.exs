defmodule Task028IndependentQA do
  use ExUnit.Case, async: false
  @moduletag :integration
  import Ecto.Query
  import FootballMarket.MarketCase
  alias FootballMarket.{Market, Repo}
  alias FootballMarket.Market.Holding

  test "retry after original holding row disappears retains original evidence and later quotes" do
    f = Map.merge(private_schema(), fixture())
    assert {:ok, %{outcome: :issued, issuance: original}} = Market.initialize_player(f.player.id)
    assert {:ok, _} = transfer(f, 100)
    assert {1, nil} = Repo.delete_all(from h in Holding, where: h.player_id == ^f.player.id and h.user_id == ^f.owner.id)
    later = later_quote(f.player, "9.99")
    before = snapshot()
    Application.put_env(:football_market, :initial_issuance_recipients, [])
    assert_error(Market.initialize_player(f.player.id), :invalid_designation)
    assert snapshot() == before
    Application.put_env(:football_market, :initial_issuance_recipients, [f.owner.id])
    assert {:ok, %{outcome: :already_completed, issuance: ^original}} = Market.initialize_player(f.player.id)
    assert {:ok, ^original} = Market.get_initial_issuance(f.player.id)
    assert snapshot() == before
    assert Repo.query!("SELECT user_id,quantity FROM market_holdings").rows == [[Ecto.UUID.dump!(f.buyer.id),100]]
    assert Decimal.equal?(Repo.get!(FootballMarket.Market.Quote, later.id).unit_price, Decimal.new("9.99"))
    IO.puts("QA_ABSENT_ORIGINAL_HOLDING supply=100 original_owner=0 outcome=already_completed snapshot=unchanged")
  end
end
