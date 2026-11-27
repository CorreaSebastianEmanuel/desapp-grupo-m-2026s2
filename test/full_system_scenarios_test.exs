defmodule FootballMarket.FullSystemScenariosTest do
  use FootballMarketWeb.ConnCase, async: false

  @moduletag :integration

  import Ecto.Query

  alias FootballMarket.{Catalog, Market, Quotes, Repo, Statistics}
  alias FootballMarket.Catalog.{League, Player, Position, Season, Team}
  alias FootballMarket.Market.Holding

  @leagues [
    {"PL", "Premier League", "ARS", "Arsenal FC", "LIV", "Liverpool FC", "FWD", "Bukayo Saka", 3,
     1},
    {"BL1", "Bundesliga", "FCB", "Bayern Munich", "BVB", "Borussia Dortmund", "FWD", "Harry Kane",
     2, 1},
    {"PD", "La Liga", "RMA", "Real Madrid", "BAR", "FC Barcelona", "MID", "Jude Bellingham", 2,
     0},
    {"SA", "Serie A", "INT", "Inter Milan", "ACM", "AC Milan", "FWD", "Lautaro Martinez", 1, 1},
    {"FL1", "Ligue 1", "PSG", "Paris Saint-Germain", "OM", "Olympique Marseille", "MID",
     "Vitinha", 1, 0}
  ]

  test "five-league ingestion, dated quotes, four users, five-player trades, portfolios, ranking, and metrics" do
    admin = create_admin!("cp3-admin@example.com")
    {:ok, _} = Market.credit_account(admin.id, Decimal.new("1000.00"))
    investors = create_funded_investors!()

    positions = seed_positions!()
    %{mapping: mapping} = create_active_strategy_and_mapping!(positions)

    players = ingest_and_issue_five_leagues!()

    today = Date.utc_today()
    day_1 = Date.add(today, -2)
    day_2 = Date.add(today, -1)

    quoted_players = publish_dated_quotes!(players, mapping.id, day_1, day_2)

    assert_historical_quotes!(hd(investors), quoted_players, today)
    assert_cached_ranking!(hd(investors))
    execute_multi_user_trades!(investors, quoted_players)
    assert_supply_and_portfolios!(investors, quoted_players, today)
    assert_business_metrics!(admin)
  end

  defp create_funded_investors! do
    for idx <- 1..4 do
      user = create_user!("cp3-investor-#{idx}@example.com")
      {:ok, _} = Market.credit_account(user.id, Decimal.new("5000.00"))
      user
    end
  end

  defp seed_positions! do
    {:ok, gk} = Catalog.create_position(%{code: "GK", name: "Goalkeeper"})
    {:ok, def_pos} = Catalog.create_position(%{code: "DEF", name: "Defender"})
    {:ok, mid} = Catalog.create_position(%{code: "MID", name: "Midfielder"})
    {:ok, fwd} = Catalog.create_position(%{code: "FWD", name: "Forward"})
    %{gk: gk, def: def_pos, mid: mid, fwd: fwd}
  end

  defp ingest_and_issue_five_leagues! do
    players = Enum.map(@leagues, &ingest_league!/1)
    assert length(players) == 5

    first_snapshot = league_snapshot(hd(@leagues))
    assert {:ok, repeat} = Catalog.import_catalog(first_snapshot, provider: "football-data-org")
    assert repeat.players == 1

    for entry <- players do
      assert {:ok, %{outcome: :issued}} = Market.initialize_player(entry.player.id)
    end

    players
  end

  defp ingest_league!(tuple) do
    {code, _name, home_code, _home_name, away_code, _away_name, _pos, _player_name, goals,
     assists} = tuple

    snapshot = league_snapshot(tuple)
    {:ok, summary} = Catalog.import_catalog(snapshot, provider: "football-data-org")
    assert summary.teams == 2
    assert summary.players == 1

    league = Repo.get_by!(League, code: code)
    season = Repo.get_by!(Season, league_id: league.id, start_year: 2026, end_year: 2027)
    home_team = Repo.get_by!(Team, season_id: season.id, code: home_code)
    away_team = Repo.get_by!(Team, season_id: season.id, code: away_code)
    player = Repo.get_by!(Player, team_id: home_team.id)
    position = Repo.get!(Position, player.position_id)

    %{
      league: league,
      season: season,
      home_team: home_team,
      away_team: away_team,
      player: player,
      position: position,
      goals: goals,
      assists: assists
    }
  end

  defp publish_dated_quotes!(players, mapping_id, day_1, day_2) do
    Enum.map(players, fn entry ->
      q1 = ingest_and_publish_quote!(entry, mapping_id, day_1, 1, 0, "md1")

      q2 =
        ingest_and_publish_quote!(entry, mapping_id, day_2, entry.goals, entry.assists, "md2")

      assert q1.quote.performance_sequence == 1
      assert q2.quote.performance_sequence == 2
      assert q1.quote.id != q2.quote.id

      Map.merge(entry, %{day_1_quote: q1.quote, day_2_quote: q2.quote})
    end)
  end

  defp assert_historical_quotes!(user, quoted_players, today) do
    conn = build_conn() |> with_jwt(user)
    today_iso = Date.to_iso8601(today)
    before_iso = Date.to_iso8601(Date.add(today, -1))

    for entry <- quoted_players do
      current =
        conn
        |> get("/api/players/#{entry.player.id}/quotes/current")
        |> json_response(200)

      assert current["data"]["id"] == entry.day_2_quote.id

      at_today =
        conn
        |> get("/api/players/#{entry.player.id}/quotes/at?date=#{today_iso}")
        |> json_response(200)

      assert at_today["data"]["id"] == entry.day_2_quote.id

      assert conn
             |> get("/api/players/#{entry.player.id}/quotes/at?date=#{before_iso}")
             |> json_response(404) == %{"error" => %{"code" => "quote_not_found"}}

      history =
        conn
        |> get("/api/players/#{entry.player.id}/quotes/history")
        |> json_response(200)

      assert length(history["data"]) == 3
      assert Enum.map(history["data"], & &1["id"]) |> Enum.member?(entry.day_1_quote.id)
      assert Enum.map(history["data"], & &1["id"]) |> Enum.member?(entry.day_2_quote.id)
    end
  end

  defp assert_cached_ranking!(user) do
    conn = build_conn() |> with_jwt(user)
    ranking_1 = conn |> get("/api/ranking") |> json_response(200)
    ranking_2 = conn |> get("/api/ranking") |> json_response(200)

    assert length(ranking_1["data"]) == 5
    assert ranking_1["data"] == ranking_2["data"]

    prices = Enum.map(ranking_1["data"], &Decimal.new(&1["unit_price"]))
    assert prices == Enum.sort(prices, &(Decimal.compare(&1, &2) != :lt))
  end

  defp execute_multi_user_trades!([u1, u2, u3, u4], [p1, p2, p3, p4, p5]) do
    trades = [
      {u1, :jwt, p1, 3, "cp3-u1-p1"},
      {u1, :jwt, p2, 2, "cp3-u1-p2"},
      {u2, :api_key, p2, 4, "cp3-u2-p2"},
      {u2, :api_key, p3, 2, "cp3-u2-p3"},
      {u3, :jwt, p3, 1, "cp3-u3-p3"},
      {u3, :jwt, p4, 5, "cp3-u3-p4"},
      {u4, :api_key, p4, 2, "cp3-u4-p4"},
      {u4, :api_key, p5, 3, "cp3-u4-p5"}
    ]

    for {user, auth_mode, entry, quantity, request_key} <- trades do
      buy =
        authed_conn(user, auth_mode)
        |> post("/api/purchases", %{
          "player_id" => entry.player.id,
          "quantity" => quantity,
          "request_key" => request_key
        })
        |> json_response(200)

      assert buy["data"]["quantity"] == quantity
      assert buy["data"]["unit_price"] == format_money(entry.day_2_quote.unit_price)
    end

    replay =
      authed_conn(u1, :jwt)
      |> post("/api/purchases", %{
        "player_id" => p1.player.id,
        "quantity" => 3,
        "request_key" => "cp3-u1-p1"
      })
      |> json_response(200)

    assert replay["data"]["quantity"] == 3

    sale =
      authed_conn(u1, :jwt)
      |> post("/api/sales", %{
        "player_id" => p1.player.id,
        "quantity" => 1,
        "request_key" => "cp3-u1-p1-sell"
      })
      |> json_response(200)

    assert sale["data"]["quantity"] == 1
  end

  defp assert_supply_and_portfolios!([u1, u2, u3, u4], [p1, p2, p3, p4, p5] = players, today) do
    for entry <- players do
      total_supply =
        Repo.aggregate(
          from(h in Holding, where: h.player_id == ^entry.player.id),
          :sum,
          :quantity
        )

      assert total_supply == 100
    end

    expected_holdings = [
      {u1, [{p1, 2}, {p2, 2}], 3},
      {u2, [{p2, 4}, {p3, 2}], 2},
      {u3, [{p3, 1}, {p4, 5}], 2},
      {u4, [{p4, 2}, {p5, 3}], 2}
    ]

    today_iso = Date.to_iso8601(today)

    for {user, expected_positions, expected_tx_count} <- expected_holdings do
      assert_user_portfolio!(user, expected_positions, expected_tx_count, today_iso)
    end
  end

  defp assert_user_portfolio!(user, expected_positions, expected_tx_count, today_iso) do
    conn = build_conn() |> with_jwt(user)
    alloc = conn |> get("/api/portfolio/allocation") |> json_response(200)
    positions_by_player = Map.new(alloc["data"]["positions"], &{&1["player_id"], &1})

    assert map_size(positions_by_player) == length(expected_positions)
    assert alloc["data"]["totals"]["valuation_complete"] == true

    expected_total_value =
      Enum.reduce(expected_positions, Decimal.new("0.00"), fn {entry, qty}, acc ->
        pos = Map.fetch!(positions_by_player, entry.player.id)
        assert pos["quantity"] == qty
        expected_val = Decimal.mult(entry.day_2_quote.unit_price, qty)
        assert Decimal.equal?(Decimal.new(pos["market_value"]), expected_val)
        Decimal.add(acc, expected_val)
      end)

    assert Decimal.equal?(
             Decimal.new(alloc["data"]["totals"]["market_value"]),
             expected_total_value
           )

    history =
      conn
      |> get("/api/portfolio/history?from=#{today_iso}&to=#{today_iso}")
      |> json_response(200)

    assert length(history["data"]["points"]) == 1

    txs = conn |> get("/api/transactions?page_size=20") |> json_response(200)
    assert length(txs["data"]) == expected_tx_count
  end

  defp assert_business_metrics!(admin) do
    metrics =
      build_conn() |> with_jwt(admin) |> get("/api/business-metrics") |> json_response(200)

    assert metrics["data"]["basis"] == "retained_local_records"
    assert metrics["data"]["quotes"]["counts"]["performance_quotes"] == 10
    assert metrics["data"]["portfolio_activity"]["counts"]["purchases"]["count"] == 8
    assert metrics["data"]["portfolio_activity"]["counts"]["purchases"]["token_quantity"] == 22
    assert metrics["data"]["portfolio_activity"]["counts"]["sales"]["count"] == 1
    assert metrics["data"]["portfolio_activity"]["counts"]["sales"]["token_quantity"] == 1
    assert metrics["data"]["ingestion"]["counts"]["performance_records"] == 10
  end

  defp league_snapshot(
         {code, _name, home_code, home_name, away_code, away_name, pos_code, player_name, _goals,
          _assists}
       ) do
    %{
      league_code: code,
      start_year: 2026,
      end_year: 2027,
      teams: [
        %{code: home_code, name: home_name},
        %{code: away_code, name: away_name}
      ],
      players: [
        %{
          team_code: home_code,
          position_code: pos_code,
          catalog_identity: "cp3-#{String.downcase(code)}-#{String.downcase(home_code)}",
          display_name: player_name
        }
      ]
    }
  end

  defp ingest_and_publish_quote!(entry, mapping_id, date, goals, assists, tag) do
    kickoff = DateTime.new!(date, ~T[18:00:00.000000], "Etc/UTC")

    envelope = %{
      match: %{
        season_id: entry.season.id,
        home_team_id: entry.home_team.id,
        away_team_id: entry.away_team.id,
        match_identity: "#{entry.league.code}-2026-#{tag}-#{entry.home_team.code}",
        kickoff_at: kickoff
      },
      performances: [
        %{
          player_id: entry.player.id,
          team_id: entry.home_team.id,
          position_id: entry.player.position_id,
          minutes_played: 90,
          goals: goals,
          assists: assists,
          shots_on_target: goals + 2,
          tackles: 2,
          interceptions: 1,
          saves: 0,
          goals_conceded: 0,
          yellow_cards: 0,
          red_cards: 0
        }
      ]
    }

    assert {:ok, imported} =
             Statistics.import_performances(entry.season.id, [envelope],
               provider: "fotmob-public-html",
               player_id: entry.player.id
             )

    assert imported.matches_added == 1
    assert imported.performances_added == 1

    assert {:ok, reimported} =
             Statistics.import_performances(entry.season.id, [envelope],
               provider: "fotmob-public-html",
               player_id: entry.player.id
             )

    assert reimported.matches_added == 0
    assert reimported.performances_added == 0

    week_start = DateTime.new!(date, ~T[00:00:00.000000], "Etc/UTC")
    week_end = DateTime.new!(date, ~T[23:59:59.000000], "Etc/UTC")

    {:ok, published} =
      Quotes.calculate_and_publish(
        %{
          player_id: entry.player.id,
          season_id: entry.season.id,
          week_start: week_start,
          week_end: week_end
        },
        :active,
        mapping_id
      )

    published
  end

  defp authed_conn(user, :jwt), do: build_conn() |> with_jwt(user)
  defp authed_conn(user, :api_key), do: build_conn() |> with_api_key(user)
  defp format_money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)
end
