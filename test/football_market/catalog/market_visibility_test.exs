defmodule FootballMarket.Catalog.MarketVisibilityTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  import FootballMarket.CatalogCase
  alias FootballMarket.{Catalog, Repo, Statistics, FreshnessCase, Synchronization}
  alias FootballMarket.Statistics.Ingestion.ScopeCheck
  alias FootballMarket.Synchronization.Run

  test "known unverified source failures are hidden before bounding and pagination" do
    %{players: [alpha, beta, gamma, delta, omega], team: team} =
      insert_catalog!(["Alpha hidden", "Beta", "Gamma hidden", "Delta", "Omega"])

    reject!(alpha, "unsupported_capability")
    reject!(gamma, "invalid_response")
    filters = %{team_id: team.id}
    {:ok, first} = market_page(filters, 2)
    assert Enum.map(first.players, & &1.id) == [beta.id, delta.id]
    assert first.pagination.returned_count == 2
    assert first.pagination.has_more
    {:ok, final} = market_page(filters, 2, first.pagination.next_cursor)
    assert Enum.map(final.players, & &1.id) == [omega.id]
    refute final.pagination.has_more
    assert final.pagination.next_cursor == nil
    assert {:ok, %{players: []}} = market_page(%{search_name: "hidden"})

    # General catalog APIs, direct cards and background preload keep their rows.
    assert {:ok, %{players: all}} = Catalog.list_player_page(%{page_size: 10, filters: filters})
    assert length(all) == 5
    assert {:ok, _} = Catalog.get_player_detail(alpha.id)
    assert Enum.any?(Catalog.list_players_for_statistics(), &(&1.id == alpha.id))
    assert {:ok, [_, _]} = Catalog.search_local_players("hidden")
  end

  test "initial pending checks and transient failures do not hide catalog players" do
    %{players: [initial, timeout, unavailable, limited, pending]} =
      insert_catalog!(["Initial", "Timeout", "Unavailable", "Limited", "Pending"])

    reject!(timeout, "timeout")
    reject!(unavailable, "unavailable")
    reject!(limited, "rate_limited")
    reject!(pending, "invalid_response", %{state: "retry_wait"})
    {:ok, page} = market_page(%{})

    assert MapSet.new(page.players, & &1.id) ==
             MapSet.new([initial, timeout, unavailable, limited, pending], & &1.id)
  end

  test "a prior source rejection stays hidden while its new version is pending" do
    %{players: [player]} = insert_catalog!()
    reject!(player, "unsupported_capability")
    reject!(player, "rate_limited", %{state: "retry_wait"})
    assert {:ok, %{players: []}} = market_page(%{})
    assert {:ok, _} = Catalog.get_player_detail(player.id)
  end

  test "unrelated players, seasons and catalog operations cannot hide a player" do
    %{players: [player, other]} = insert_catalog!(["Target", "Other"])
    reject!(other, "invalid_response")
    reject!(player, "invalid_response", %{start_year: 2030, end_year: 2031})
    reject!(player, "invalid_response", %{operation: "catalog"})
    {:ok, page} = market_page(%{})
    assert Enum.map(page.players, & &1.id) == [player.id]
  end

  test "existing immutable match facts stay visible after a later source failure" do
    f = FootballMarket.StatisticsCase.fixture()
    player = hd(f.players)
    {:ok, match} = Statistics.record_match(FootballMarket.StatisticsCase.match_attrs(f))

    {:ok, performance} =
      Statistics.record_performance(FootballMarket.StatisticsCase.performance_attrs(f, match))

    reject!(player, "invalid_response")
    before = FootballMarket.QuotesCase.protected_snapshot()
    {:ok, page} = market_page(%{})
    assert Enum.any?(page.players, &(&1.id == player.id))
    assert FootballMarket.QuotesCase.protected_snapshot() == before
    assert Repo.get!(FootballMarket.Statistics.Performance, performance.id) == performance
  end

  test "a later accepted empty player check restores visibility without fabricating performances" do
    f = FreshnessCase.fixture()
    reject!(f.player, "unsupported_capability")
    assert {:ok, %{players: []}} = market_page(%{})

    candidate =
      FootballMarket.StatisticsIngestion.Case.candidate(
        FootballMarket.StatisticsIngestion.Fixtures.request(f.scope),
        matches: [],
        performances: []
      )
      |> put_in([:completeness, :full_scope], "player")

    source = FootballMarket.StatisticsIngestion.Case.source(candidate)
    sync = Application.get_env(:football_market, Synchronization)

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(sync, :sources, %{"freshness-fixture" => source})
    )

    source_id = Catalog.provider_player_id(f.player.id, "synthetic-a")
    assert is_binary(source_id)
    options = Keyword.merge(f.options, player_id: f.player.id, player_source_id: source_id)
    FreshnessCase.config(:refresh_options_by_scope, %{{"PL", 2025, 2026} => options})

    FreshnessCase.perform!(f)

    assert %ScopeCheck{last_checked_at: checked, last_accepted_check_id: accepted} =
             Repo.get_by!(ScopeCheck, player_id: f.player.id)

    assert checked && accepted
    assert Repo.aggregate(FootballMarket.Statistics.Performance, :count) == 0
    assert {:ok, %{players: [visible]}} = market_page(%{})
    assert visible.id == f.player.id

    reject!(f.player, "invalid_response")
    assert {:ok, %{players: [still_visible]}} = market_page(%{})
    assert still_visible.id == f.player.id
  end

  defp market_page(filters, size \\ 10, cursor \\ nil),
    do: Catalog.list_market_player_page(%{page_size: size, cursor: cursor, filters: filters})

  defp reject!(player, category, overrides \\ %{}) do
    season = player.team.season

    attributes = %{
      operation: "statistics",
      league_code: season.league.code,
      start_year: season.start_year,
      end_year: season.end_year,
      correlation_id: Ecto.UUID.generate(),
      source_ref: "market-visibility-fixture",
      input: %{"player_id" => player.id},
      input_digest: Ecto.UUID.generate(),
      policy: %{"attempt_limit" => 1},
      original_trigger: "manual",
      state: "failed",
      requested_at: DateTime.utc_now(),
      finished_at: DateTime.utc_now(),
      reason: "non_retryable",
      outcome: %{"status" => "provider_failure", "category" => category}
    }

    Repo.insert!(struct!(Run, Map.merge(attributes, overrides)))
  end
end
