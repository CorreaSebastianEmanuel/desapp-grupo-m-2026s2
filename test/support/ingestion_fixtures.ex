defmodule FootballMarket.IngestionFixtures do
  @moduledoc false
  alias FootballMarket.{Catalog, Repo}
  alias FootballMarket.Accounts.User

  @test_primary_id "00000000-0000-4000-8000-000000000085"

  defmacro __using__(_options) do
    quote do
      import FootballMarket.IngestionFixtures

      setup do
        restore = FootballMarket.IngestionFixtures.setup_primary_account!()
        on_exit(restore)
        :ok
      end
    end
  end

  def setup_primary_account! do
    previous = Application.get_env(:football_market, :initial_issuance_recipients, [])

    recipient = Repo.get(FootballMarket.Market.InitialRecipient, 1)

    user =
      if recipient do
        Repo.get!(User, recipient.user_id)
      else
        Repo.get(User, @test_primary_id) ||
          Repo.insert!(%User{id: @test_primary_id, email: "primary-task085@example.com"})
      end

    Application.put_env(:football_market, :initial_issuance_recipients, [user.id])
    fn -> Application.put_env(:football_market, :initial_issuance_recipients, previous) end
  end

  @leagues [
    {"PL", "Premier League"},
    {"BL1", "Bundesliga"},
    {"PD", "La Liga"},
    {"SA", "Serie A"},
    {"FL1", "Ligue 1"}
  ]
  def leagues, do: @leagues

  def request(code \\ "PL", year \\ 2025),
    do: %{league_code: code, start_year: year, end_year: year + 1}

  def candidate(code \\ "PL", year \\ 2025) do
    name = Enum.find_value(@leagues, fn {c, n} -> if c == code, do: n end)

    facts = %{
      league: %{ref: "league-ref", code: code, name: name},
      season: %{ref: "season-ref", league_ref: "league-ref", start_year: year, end_year: year + 1},
      teams: [
        %{ref: "team-a", season_ref: "season-ref", code: "ALP", name: "Alpha"},
        %{ref: "team-b", season_ref: "season-ref", code: "BET", name: "Beta"}
      ],
      positions: [%{ref: "GK", code: "GK", name: "Goalkeeper"}],
      players: [
        %{
          ref: "player-a",
          season_ref: "season-ref",
          team_ref: "team-a",
          position_ref: "GK",
          display_name: "Alex"
        }
      ]
    }

    %{
      operation: :catalog,
      scope: request(code, year),
      facts: facts,
      fixture_id: "independent-catalog",
      bindings: [
        %{kind: :league, ref: "league-ref", source_id: "league-id"},
        %{kind: :season, ref: "season-ref", source_id: "season-id"},
        %{kind: :team, ref: "team-a", source_id: "team-A"},
        %{kind: :team, ref: "team-b", source_id: "team-B"},
        %{kind: :player, ref: "player-a", source_id: "player-A"}
      ]
    }
  end

  def publication_failpoint(point), do: Process.put(:catalog_ingestion_failpoint, point)

  def expected_rows, do: [{"Alex", "ALP", "Alpha", "GK"}]

  def expected_initial_counts,
    do: %{
      "league" => %{"created" => 1, "updated" => 0, "unchanged" => 0},
      "season" => %{"created" => 1, "updated" => 0, "unchanged" => 0},
      "team" => %{"created" => 2, "updated" => 0, "unchanged" => 0},
      "player" => %{"created" => 1, "updated" => 0, "unchanged" => 0}
    }

  def positions! do
    case Repo.get_by(FootballMarket.Catalog.Position, code: "GK") do
      nil ->
        {:ok, position} = Catalog.create_position(%{code: "GK", name: "Goalkeeper"})
        position

      position ->
        position
    end
  end

  def options(candidate \\ candidate(), instant \\ ~U[2026-10-06 12:00:00.000000Z]) do
    ensure_test_primary_account!()

    [
      provider: {FootballMarket.IngestionFixtureAdapter, candidate},
      runtime: {FootballMarket.IngestionFixtureRuntime, %{instant: instant}}
    ]
  end

  defp ensure_test_primary_account! do
    unless Repo.get(User, @test_primary_id) do
      Repo.insert!(%User{id: @test_primary_id, email: "primary-task085@example.com"})
    end
  end

  def snapshot do
    for table <-
          ~w(leagues seasons teams positions players users password_credentials api_keys matches player_match_performances),
        into: %{} do
      rows =
        Ecto.Adapters.SQL.query!(
          Repo,
          "SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text",
          []
        ).rows

      {table,
       if(table in ~w(users password_credentials api_keys),
         do: :crypto.hash(:sha256, Jason.encode!(rows)),
         else: rows
       )}
    end
  end

  def acceptance_snapshot do
    for table <-
          ~w(catalog_ingestion_scopes catalog_source_bindings catalog_ingestion_observations catalog_ingestion_observation_bindings),
        into: %{} do
      {table,
       Ecto.Adapters.SQL.query!(
         Repo,
         "SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text",
         []
       ).rows}
    end
  end

  def mapping(kind, source, target, provider \\ "synthetic-a", code \\ "PL", year \\ 2025),
    do: %{
      provider: provider,
      league_code: code,
      start_year: year,
      end_year: year + 1,
      kind: kind,
      source_id: source,
      target_id: target
    }

  def rereference(c) do
    rename = fn ref -> "alternate-" <> ref end

    %{
      c
      | facts: %{
          c.facts
          | league: %{c.facts.league | ref: rename.(c.facts.league.ref)},
            season: %{
              c.facts.season
              | ref: rename.(c.facts.season.ref),
                league_ref: rename.(c.facts.season.league_ref)
            },
            teams:
              Enum.reverse(
                Enum.map(
                  c.facts.teams,
                  &%{&1 | ref: rename.(&1.ref), season_ref: rename.(&1.season_ref)}
                )
              ),
            players:
              Enum.reverse(
                Enum.map(
                  c.facts.players,
                  &%{
                    &1
                    | ref: rename.(&1.ref),
                      season_ref: rename.(&1.season_ref),
                      team_ref: rename.(&1.team_ref)
                  }
                )
              )
        },
        bindings: Enum.reverse(Enum.map(c.bindings, &%{&1 | ref: rename.(&1.ref)}))
    }
  end
end

defmodule FootballMarket.IngestionFixtureAdapter do
  @moduledoc false
  @behaviour FootballMarket.Providers.Adapter
  def provider_label, do: "synthetic-a"

  def read(request, _context, candidate) do
    Process.put(
      :statistics_ingestion_transport_calls,
      Process.get(:statistics_ingestion_transport_calls, 0) + 1
    )

    case candidate do
      {:barrier, parent, token, map} ->
        %{rows: [[backend]]} = FootballMarket.Repo.query!("SELECT pg_backend_pid()", [])

        send(parent, {token, self(), backend})

        receive do
          {^token, :go} -> {:ok, %{map | scope: request.scope}}
        after
          5000 -> {:error, %{category: :unavailable}}
        end

      {:notify, parent, map} ->
        send(parent, :source_called)
        {:ok, %{map | scope: request.scope}}

      {:error, failure} ->
        {:error, failure}

      map ->
        {:ok, %{map | scope: request.scope}}
    end
  end
end

defmodule FootballMarket.IngestionFixtureRuntime do
  @moduledoc false
  def now_us(_), do: 0
  def utc_now(state), do: state.instant
  def launch(fun, _deadline, _state), do: fun.()
  def await(outcome, _deadline, _state), do: {:ready, outcome, 0}
  def cancel(_, _), do: :ok
  def close(_, _), do: :ok
end

defmodule FootballMarket.IngestionReplacementAdapter do
  @moduledoc false
  @behaviour FootballMarket.Providers.Adapter
  def provider_label, do: "synthetic-b"

  def read(request, context, candidate),
    do: FootballMarket.IngestionFixtureAdapter.read(request, context, candidate)
end

defmodule FootballMarket.IngestionLateRuntime do
  @moduledoc false
  def now_us(_), do: 0
  def utc_now(_), do: ~U[2026-10-06 12:00:00.000000Z]
  def launch(fun, _deadline, _state), do: fun.()
  def await(outcome, deadline, _state), do: {:ready, outcome, deadline}
  def cancel(_, _), do: :ok
  def close(_, _), do: :ok
end
