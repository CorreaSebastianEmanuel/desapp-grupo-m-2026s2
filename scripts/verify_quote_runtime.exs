alias FootballMarket.Repo
alias FootballMarket.Quotes.Conversion

defmodule QuoteRuntimeAssertions do
  def assert!(true, _message), do: :ok
  def assert!(_, message), do: raise("quote runtime assertion failed: #{message}")
end

QuoteRuntimeAssertions.assert!(Repo.query!("SELECT 1").rows == [[1]], "PostgreSQL readiness")

# Public job rows are shared state; note the run start so the tail cleanup can
# remove quote calculation jobs inserted through this run's acceptance path.
started = DateTime.utc_now() |> DateTime.truncate(:microsecond)

assert_conversion = fn score, scale, expected ->
  case Conversion.convert(Decimal.new(score), Decimal.new(scale)) do
    {:ok, price} -> Decimal.equal?(price, Decimal.new(expected))
    _ -> false
  end
end

QuoteRuntimeAssertions.assert!(
  assert_conversion.("2.000000", "1.25", "2.50"),
  "exact positive quote"
)

QuoteRuntimeAssertions.assert!(assert_conversion.("1.005", "1", "1.01"), "ties away from zero")

QuoteRuntimeAssertions.assert!(
  Conversion.convert(Decimal.new("0.004"), Decimal.new("1")) ==
    {:no_quote, :nonpositive_converted_result},
  "rounded zero is not quotable"
)

QuoteRuntimeAssertions.assert!(
  Code.ensure_loaded!(FootballMarket.Quotes.EvidenceCodec) &&
    function_exported?(FootballMarket.Quotes.EvidenceCodec, :decode_facts, 1),
  "typed evidence decoder exists"
)

Code.require_file("test/support/quotes/runtime_probe.ex")

store = FootballMarket.Quotes.RuntimeProbe.owned_store!()
%{schema: schema, repo: client} = store
scope_year = 2086 + rem(System.system_time(:millisecond), 64)

# The orchestrator itself reads the store's durable rows: route the main
# BEAM through the owned store's connection until cleanup reverts it.
previous_repo = Repo.put_dynamic_repo(client)

# Process one: real statistics ingestion acceptance for a fresh scope. The
# committed import creates a durable pending calculation intent; the documented
# accept contract (the same product call the dispatcher's delivery runs) pins
# the immutable weekly membership and creates exactly one pending quote request
# with one available QuoteCalculation job in the store's own oban_jobs. This
# BEAM never drains it, mirroring a killed dispatch worker that dies before any
# quote calculation runs.
process_one = """
import Ecto.Query

alias FootballMarket.Repo
alias FootballMarket.Statistics.Ingestion.CalculationIntent
alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

schema = System.fetch_env!("QUOTE_SCHEMA")
{:ok, client} = Repo.start_link(name: nil, pool: DBConnection.ConnectionPool, pool_size: 3, parameters: [search_path: schema])
Repo.put_dynamic_repo(client)

Code.require_file("test/support/ingestion_fixtures.ex")
Code.require_file("test/support/statistics_ingestion/case.ex")
Code.require_file("test/support/statistics_ingestion/fixtures.ex")

scope = Fixtures.scope(String.to_integer(System.fetch_env!("QUOTE_SCOPE_YEAR")))
Case.seed_catalog!(scope)

candidate =
  Case.candidate(Fixtures.request(scope),
    performances: [
      %{
        ref: "performance-1",
        match_ref: "match-1",
        player_ref: "player-a",
        team_ref: "team-a",
        position_ref: "GK",
        minutes_played: 90,
        counts: %{goals: 1, assists: nil}
      }
    ]
  )

player = Repo.one!(from p in FootballMarket.Catalog.Player, where: p.display_name == "Alex")
{:ok, user} =
  FootballMarket.Accounts.register_user(%{
    email: "quote-runtime-#{Ecto.UUID.generate()}@example.test",
    password: "quote-runtime-password"
  })

Application.put_env(:football_market, :initial_issuance_recipients, [user.id])
{:ok, %{outcome: :issued}} = FootballMarket.Market.initialize_player(player.id)

{:ok, configuration} =
  FootballMarket.Valuation.Configurations.create(%{
    strategy_id: "balanced",
    formula_version: "1",
    config: %{weights: %{goals: 2}},
    references: %{goals: 2},
    position_mapping: [{player.position_id, :defender}]
  })

{:ok, _selection} = FootballMarket.Valuation.Configurations.activate(configuration.id, nil)

context = Case.delivery_context!(scope)

{:ok, outcome} =
  FootballMarket.Statistics.Ingestion.import_scope(scope, Case.provider_options(candidate) ++ [delivery_context: context])

intent = Repo.get!(CalculationIntent, outcome.calculation_intent_id)
true = intent.state == "pending"

{:ok, mapping} = FootballMarket.Quotes.save_mapping("quote-runtime", Ecto.UUID.generate(), Decimal.new("1.25"))
Application.put_env(:football_market, :quote_mapping_id, mapping.id)

{:ok, _request} =
  FootballMarket.Valuation.CalculationRequests.accept(
    intent.id,
    intent.accepted_check_id,
    intent.changed_performance_ids
  )

quote_request_state =
  Repo.one!(
    from r in FootballMarket.Quotes.CalculationRequest,
      where: r.intent_id == ^intent.id,
      select: r.state
  )

true = quote_request_state == "pending"

jobs =
  Repo.query!("SELECT count(*) FROM oban_jobs WHERE worker='FootballMarket.Workers.QuoteCalculation' AND state='available'").rows
  |> hd() |> hd()

true = jobs == 1

undelivered =
  Repo.query!("SELECT count(*) FROM statistics_calculation_intents WHERE state='delivered'").rows |> hd() |> hd()

true = undelivered == 0

IO.puts("QUOTE_ACCEPTED=" <> intent.id)
"""

producer_output =
  FootballMarket.Quotes.RuntimeProbe.fresh_beam!(process_one, [
    {"QUOTE_SCHEMA", schema},
    {"QUOTE_SCOPE_YEAR", Integer.to_string(scope_year)}
  ])

intent =
  case String.split(producer_output, "QUOTE_ACCEPTED=") do
    [_head, tail] -> tail |> String.split("\n") |> hd() |> String.trim()
    _ -> raise "quote runtime assertion failed: process one did not print the accepted intent"
  end

{:ok, intent_id} = Ecto.UUID.cast(intent)

request_id =
  Repo.query!("SELECT id FROM quote_calculation_requests WHERE intent_id=$1", [
    Ecto.UUID.dump!(intent_id)
  ]).rows
  |> hd()
  |> hd()
  |> Ecto.UUID.load!()

# Process two: a fresh BEAM recovers and confirms the quote calculation with
# its own manual Oban against the owned store's stranded jobs.
process_two = """
alias FootballMarket.Repo

schema = System.fetch_env!("QUOTE_SCHEMA")
{:ok, client} = Repo.start_link(name: nil, pool: DBConnection.ConnectionPool, pool_size: 3, parameters: [search_path: schema])
Repo.put_dynamic_repo(client)

{:ok, _oban} =
  Oban.start_link(
    name: FootballMarket.Quotes.RuntimeTestOban,
    repo: Repo,
    prefix: schema,
    testing: :disabled,
    queues: [],
    plugins: [],
    get_dynamic_repo: fn -> client end
  )

Application.put_env(
  :football_market,
  FootballMarket.Synchronization,
  Keyword.put(
    Application.get_env(:football_market, FootballMarket.Synchronization, []),
    :oban_name,
    FootballMarket.Quotes.RuntimeTestOban
  )
)

{:ok, recovered} = FootballMarket.Quotes.Recovery.recover_pending()
true = recovered >= 1

:ok = FootballMarket.Quotes.process_import_request(System.fetch_env!("QUOTE_REQUEST_ID"))
request = Repo.get!(FootballMarket.Quotes.CalculationRequest, System.fetch_env!("QUOTE_REQUEST_ID"))
true = request.state == "successful"

calculations = Repo.query!("SELECT count(*) FROM quote_calculations WHERE status='successful'").rows |> hd() |> hd()
true = calculations == 1

IO.puts("QUOTE_RECOVERED=" <> System.fetch_env!("QUOTE_REQUEST_ID"))
"""

recovery_output =
  FootballMarket.Quotes.RuntimeProbe.fresh_beam!(process_two, [
    {"QUOTE_SCHEMA", schema},
    {"QUOTE_REQUEST_ID", request_id}
  ])

case String.split(recovery_output, "QUOTE_RECOVERED=") do
  [_head, _tail] -> :ok
  _ -> raise "quote runtime assertion failed: fresh process did not recover the quote"
end

# Process three: a fresh BEAM replays the persisted original from evidence
# only, redelivers the same request, then accepts a late fact under a newly
# active strategy version. The original stays unchanged while the fresh result
# is checked against an independently known score, scale and ties-away price.
process_three = """
import Ecto.Query

alias FootballMarket.Repo
alias FootballMarket.Quotes.Calculation
alias FootballMarket.Statistics.Ingestion.CalculationIntent
alias FootballMarket.StatisticsIngestion.{Case, Fixtures}
alias FootballMarket.Valuation.{CalculationRequests, Configurations}

schema = System.fetch_env!("QUOTE_SCHEMA")
{:ok, client} = Repo.start_link(name: nil, pool: DBConnection.ConnectionPool, pool_size: 3, parameters: [search_path: schema])
Repo.put_dynamic_repo(client)

Code.require_file("test/support/ingestion_fixtures.ex")
Code.require_file("test/support/statistics_ingestion/case.ex")
Code.require_file("test/support/statistics_ingestion/fixtures.ex")

calculation = Repo.one!(from c in Calculation, where: c.status == "successful", limit: 1)

true = calculation.status == "successful"
true = is_binary(calculation.configuration_version_id) and is_binary(calculation.mapping_id)
original_membership = calculation.membership
original_price = calculation.unit_price
player = Repo.get!(FootballMarket.Catalog.Player, calculation.player_id)
Application.put_env(:football_market, :quote_mapping_id, calculation.mapping_id)

{:ok, replay} = FootballMarket.Quotes.replay(calculation.id)
true = replay.calculation.id == calculation.id
true = replay.calculation.status == "successful"
true = replay.calculation.membership == original_membership
true = Decimal.equal?(replay.score, calculation.score)
true = Decimal.equal?(replay.outcome.price, calculation.unit_price)

counts = fn ->
  Repo.query!(
    "SELECT (SELECT count(*) FROM market_quotes), (SELECT count(*) FROM quote_evaluation_requests), (SELECT count(*) FROM quote_calculations), (SELECT count(*) FROM quote_calculation_requests)"
  ).rows
end

before = counts.()

:ok =
       FootballMarket.Workers.QuoteCalculation.perform(%Oban.Job{
         args: %{"request_id" => System.fetch_env!("QUOTE_REQUEST_ID")}
       })

after_retry = counts.()
true = before == after_retry

{:ok, next_configuration} =
  Configurations.create(%{
    strategy_id: "balanced",
    formula_version: "1",
    config: %{weights: %{goals: Decimal.new("1.005")}},
    references: %{goals: Decimal.new("5")},
    position_mapping: [{player.position_id, :defender}]
  })

{:ok, _selection} = Configurations.activate(next_configuration.id, calculation.configuration_version_id)

scope = Fixtures.scope(String.to_integer(System.fetch_env!("QUOTE_SCOPE_YEAR")))
scope_map = Map.take(scope, [:league_code, :start_year, :end_year])
candidate =
  Case.candidate(Fixtures.request(scope),
    matches: [
      %{
        ref: "match-1",
        scope: scope_map,
        season_ref: "season-ref",
        status: :completed,
        kickoff_at: ~U[2026-01-01 12:00:00Z],
        home_team_ref: "team-a",
        away_team_ref: "team-b"
      },
      %{
        ref: "match-late",
        scope: scope_map,
        season_ref: "season-ref",
        status: :completed,
        kickoff_at: ~U[2026-01-02 12:00:00Z],
        home_team_ref: "team-a",
        away_team_ref: "team-b"
      }
    ],
    performances: [
      %{
        ref: "performance-1",
        match_ref: "match-1",
        player_ref: "player-a",
        team_ref: "team-a",
        position_ref: "GK",
        minutes_played: 90,
        counts: %{goals: 1, assists: nil}
      },
      %{
        ref: "performance-late",
        match_ref: "match-late",
        player_ref: "player-a",
        team_ref: "team-a",
        position_ref: "GK",
        minutes_played: 90,
        counts: %{goals: 3, assists: nil}
      }
    ]
  )

delivery = Case.delivery_context!(scope)
{:ok, accepted} =
  FootballMarket.Statistics.Ingestion.import_scope(
    scope,
    Case.provider_options(candidate) ++ [delivery_context: delivery]
  )

intent = Repo.get!(CalculationIntent, accepted.calculation_intent_id)
{:ok, _request} =
  CalculationRequests.accept(intent.id, intent.accepted_check_id, intent.changed_performance_ids)

late_request = Repo.one!(from r in FootballMarket.Quotes.CalculationRequest, where: r.intent_id == ^intent.id)
:ok = FootballMarket.Quotes.process_import_request(late_request.id)
late_request = Repo.get!(FootballMarket.Quotes.CalculationRequest, late_request.id)
late_calculation = Repo.get!(Calculation, late_request.calculation_id)

true = late_request.state == "successful"
true = late_calculation.configuration_version_id == next_configuration.id
true = length(late_calculation.membership) == 2
true = Decimal.equal?(late_calculation.score, Decimal.new("0.804000"))
expected_unrounded = Decimal.mult(Decimal.new("0.804000"), Decimal.new("1.25"))
true = Decimal.equal?(expected_unrounded, Decimal.new("1.005"))
true = Decimal.equal?(late_calculation.unit_price, Decimal.new("1.01"))

{:ok, replay_after_late_facts} = FootballMarket.Quotes.replay(calculation.id)
true = replay_after_late_facts.calculation.membership == original_membership
true = Decimal.equal?(replay_after_late_facts.calculation.unit_price, original_price)
true = Decimal.equal?(replay_after_late_facts.outcome.price, original_price)

true = counts.() != before
true = Repo.aggregate(Calculation, :count, :id) == 2
IO.puts("QUOTE_REPLAYED=" <> calculation.id)
IO.puts("QUOTE_LATE_FACT_CONFIRMED=" <> late_calculation.id)
"""

replay_output =
  FootballMarket.Quotes.RuntimeProbe.fresh_beam!(process_three, [
    {"QUOTE_SCHEMA", schema},
    {"QUOTE_REQUEST_ID", request_id},
    {"QUOTE_SCOPE_YEAR", Integer.to_string(scope_year)}
  ])

case {String.split(replay_output, "QUOTE_REPLAYED="),
      String.split(replay_output, "QUOTE_LATE_FACT_CONFIRMED=")} do
  {[_head, _replayed], [_late_head, _late_calculation]} -> :ok
  _ -> raise "quote runtime assertion failed: replay did not return the identical outcome"
end

QuoteRuntimeAssertions.assert!(
  Repo.query!(
    "SELECT count(*) FROM quote_evaluation_requests WHERE state='pending' AND consumer_receipt IS NULL"
  ).rows == [[2]],
  "each confirmed quote has one pending quote-keyed evaluation"
)

QuoteRuntimeAssertions.assert!(
  Repo.query!("SELECT count(*) FROM market_issuances").rows == [[1]],
  "the runtime fixture has exactly one issuance"
)

QuoteRuntimeAssertions.assert!(
  Repo.query!("SELECT count(*) FROM market_quotes").rows == [[3]],
  "initial quote and both immutable performance quotes remain present"
)

QuoteRuntimeAssertions.assert!(
  Repo.query!("SELECT count(*) FROM quote_calculations WHERE status='successful'").rows == [[2]],
  "both successful fixture calculations remain persisted"
)

QuoteRuntimeAssertions.assert!(
  Repo.query!("SELECT count(*) FROM quote_evaluation_requests").rows == [[2]],
  "each confirmed performance quote has exactly one evaluation request"
)

QuoteRuntimeAssertions.assert!(
  Repo.query!("""
  SELECT count(*) FROM (
    SELECT i.player_id
    FROM market_issuances i
    JOIN market_quotes q ON q.id=i.initial_quote_id
    LEFT JOIN market_holdings h ON h.player_id=i.player_id
    GROUP BY i.player_id, q.id, i.quantity, i.initial_unit_price
    HAVING q.rule_id <> 'initial_issuance' OR q.unit_price <> 1 OR
      i.quantity <> 100 OR i.initial_unit_price <> 1 OR coalesce(sum(h.quantity), 0) <> 100
  ) broken
  """).rows == [[0]],
  "fixture issuance, initial quote and 100-unit holdings remain intact"
)

# The recovery performs durable work only inside its own BEAM; purge only this
# run's shared public oban rows so the database stays hermetic.
Repo.put_dynamic_repo(previous_repo)

Repo.query!(
  "DELETE FROM oban_jobs WHERE worker = 'FootballMarket.Workers.QuoteCalculation' AND inserted_at >= $1",
  [started]
)

FootballMarket.Quotes.RuntimeProbe.destroy_store!(store)

IO.puts("QUOTE_RUNTIME_ASSERTIONS_PASS")
