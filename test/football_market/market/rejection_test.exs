defmodule FootballMarket.Market.RejectionTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.MarketCase
  alias FootballMarket.{Market, Repo}

  setup do
    ns = private_schema()
    Map.merge(ns, fixture())
  end

  test "US3 prerequisites and assertion failures never change accounts or market", f do
    for issued <- [false, true] do
      if issued, do: assert({:ok, _} = Market.initialize_player(f.player.id))
      before = snapshot()
      assert_error(Market.initialize_player(Ecto.UUID.generate()), :player_not_found)
      assert_error(Market.get_initial_issuance(Ecto.UUID.generate()), :player_not_found)

      for setting <- [
            nil,
            [],
            [f.owner.id, f.owner.id],
            [f.owner.id, f.buyer.id],
            [Ecto.UUID.generate()]
          ] do
        Application.put_env(:football_market, :initial_issuance_recipients, setting)
        assert_error(Market.initialize_player(f.player.id), :invalid_designation)
        assert before == snapshot()
      end

      Application.put_env(:football_market, :initial_issuance_recipients, [f.owner.id])

      for attrs <- [
            %{recipient_id: f.buyer.id},
            %{quantity: 101},
            %{quantity: 100.0},
            %{unit_price: 2},
            %{unit_price: 1.0},
            %{historical_date: "2020-01-01"},
            %{invocation_id: "retry"}
          ] do
        assert_error(Market.initialize_player(f.player.id, attrs), :invalid_input)
        assert snapshot() == before
      end
    end
  end

  test "US3 original recipient governs same and future players", f do
    {:ok, _} = Market.initialize_player(f.player.id)
    before = snapshot()
    Application.put_env(:football_market, :initial_issuance_recipients, [f.buyer.id])

    for player <- [f.player, f.other] do
      assert_error(Market.initialize_player(player.id), :recipient_conflict)
      assert snapshot() == before
    end
  end

  test "US3 orphan quote or holding rejects first issuance without repair", f do
    for history <- [:quote, :holding] do
      ns = private_schema()
      local = Map.merge(ns, fixture())

      if history == :quote,
        do: invalid_performance_quote(local.player),
        else:
          Repo.insert!(%FootballMarket.Market.Holding{
            player_id: local.player.id,
            user_id: local.owner.id,
            quantity: 0
          })

      before = snapshot()
      assert snapshot() == before

      if history == :quote do
        assert {:ok, %{outcome: :issued}} = Market.initialize_player(local.player.id)
        assert Repo.query!("SELECT count(*) FROM market_issuances").rows == [[1]]
      else
        assert_error(Market.initialize_player(local.player.id), :inconsistent_state)
        assert Repo.query!("SELECT count(*) FROM market_issuances").rows == [[0]]
      end
    end

    assert f.player.id != f.other.id
  end

  test "US3 legacy contradictions override already-completed success without touching guarded originals",
       f do
    {:ok, _} = Market.initialize_player(f.player.id)
    guarded = snapshot()

    mutations = [
      "UPDATE market_holdings SET quantity=99",
      "UPDATE market_holdings SET quantity=120; INSERT INTO market_holdings VALUES(gen_random_uuid(),'#{f.player.id}','#{f.buyer.id}',-20)",
      "UPDATE market_holdings SET user_id='#{Ecto.UUID.generate()}'",
      "UPDATE market_issuances SET quantity=99",
      "UPDATE market_issuances SET initial_unit_price=2",
      "UPDATE market_issuances SET completed_at=NULL",
      "UPDATE market_issuances SET id=NULL",
      "UPDATE market_quotes SET rule_version='2'",
      "UPDATE market_quotes SET unit_price=2",
      "UPDATE market_quotes SET player_id='#{f.other.id}'",
      "DELETE FROM market_quotes",
      "DELETE FROM market_initial_recipients"
    ]

    for mutation <- mutations do
      legacy = legacy_namespace(f.schema)

      in_client(legacy, fn ->
        # Each statement uses the test-owned unconstrained legacy copy only.
        for command <- String.split(mutation, ";", trim: true), do: Repo.query!(command)
        before = snapshot()
        assert_error(Market.initialize_player(f.player.id), :inconsistent_state)
        assert before == snapshot()
      end)

      assert snapshot() == guarded
    end
  end

  test "missing legacy serialization anchor fails safely without mutation", f do
    legacy = legacy_namespace(f.schema)

    in_client(legacy, fn ->
      Repo.query!("DELETE FROM market_initialization_locks")
      before = snapshot()

      assert {:error, %{kind: :storage_failure, reason: :missing_initialization_lock}} =
               Market.initialize_player(f.player.id)

      assert snapshot() == before
    end)
  end

  test "fresh-player initialization does not repair legacy recipient fixation", f do
    {:ok, _} = Market.initialize_player(f.player.id)
    legacy = legacy_namespace(f.schema)

    in_client(legacy, fn ->
      Repo.query!("DELETE FROM market_initial_recipients")
      before = snapshot()
      assert_error(Market.initialize_player(f.other.id), :inconsistent_state)
      assert snapshot() == before
    end)
  end

  test "top-level initializer fails closed on unsupported session isolation", f do
    before = snapshot()

    Repo.checkout(fn ->
      Repo.query!("SET default_transaction_isolation='repeatable read'")

      try do
        assert {:error, %{kind: :invalid_input, reason: :unsupported_isolation}} =
                 Market.initialize_player(f.player.id)
      after
        Repo.query!("SET default_transaction_isolation='read committed'")
      end
    end)

    assert snapshot() == before
  end
end
