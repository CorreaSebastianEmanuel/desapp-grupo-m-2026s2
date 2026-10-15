defmodule FootballMarket.Market.IssuanceTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import Ecto.Query
  import FootballMarket.MarketCase
  alias FootballMarket.{Market, Repo}
  alias FootballMarket.Market.{Holding, Quote, Issuance}

  setup do
    ns = private_schema()
    Map.merge(ns, fixture())
  end

  test "US1: exact original inventory for independent season identities, no account effects", f do
    before = snapshot() |> Map.take(~w(users password_credentials api_keys balance_sentinels))
    assert_error(Market.get_initial_issuance(f.player.id), :not_initialized)
    assert market_empty?()
    team = Repo.get!(FootballMarket.Catalog.Team, f.player.team_id)
    season = Repo.get!(FootballMarket.Catalog.Season, team.season_id)

    {:ok, next} =
      FootballMarket.Catalog.create_season(%{
        league_id: season.league_id,
        start_year: 2027,
        end_year: 2028
      })

    {:ok, next_team} =
      FootballMarket.Catalog.create_team(%{season_id: next.id, code: "NEXT", name: "Next"})

    {:ok, season_player} =
      FootballMarket.Catalog.create_player(%{
        team_id: next_team.id,
        position_id: f.player.position_id,
        catalog_identity: f.player.catalog_identity,
        display_name: "Initial"
      })

    # Independent season-specific identity even for the same display name.
    for p <- [f.player, f.other, season_player] do
      assert {:ok, %{outcome: :issued, issuance: e}} = Market.initialize_player(p.id)
      assert e.player_id == p.id and e.recipient_id == f.owner.id
      assert e.quantity === 100
      assert Decimal.equal?(e.initial_unit_price, Decimal.new(1))
      assert Decimal.equal?(e.initial_inventory_value, Decimal.new(100))
      assert e.rule_id == "initial_issuance" and e.rule_version == "1"
      assert %DateTime{} = e.effective_at
      assert e.completed_at == e.effective_at
      assert {:ok, ^e} = Market.get_initial_issuance(p.id)

      assert Repo.aggregate(from(h in Holding, where: h.player_id == ^p.id), :sum, :quantity) ==
               100

      assert [%Holding{user_id: owner, quantity: 100}] =
               Repo.all(from h in Holding, where: h.player_id == ^p.id)

      assert owner == f.owner.id
      assert Repo.aggregate(from(h in Holding, where: h.user_id == ^f.buyer.id), :count) == 0
      assert Repo.get!(Quote, e.initial_quote_id).player_id == p.id
    end

    assert Repo.aggregate(Issuance, :count) == 3

    assert before ==
             snapshot() |> Map.take(~w(users password_credentials api_keys balance_sentinels))

    {:ok, original} = Market.get_initial_issuance(f.player.id)

    assert {:ok, %{display_name: "Renamed"}} =
             FootballMarket.Catalog.update_player(f.player, %{display_name: "Renamed"})

    assert {:ok, %{outcome: :already_completed, issuance: ^original}} =
             Market.initialize_player(f.player.id)
  end

  test "nested transaction cannot report a committed initialization", f do
    before = snapshot()
    assert {:ok, result} = Repo.transaction(fn -> Market.initialize_player(f.player.id) end)
    assert {:error, %{kind: :invalid_input, reason: :transaction_in_progress}} = result
    assert snapshot() == before
  end
end
