alias FootballMarket.{Repo, Quotes}
alias FootballMarket.Quotes.{Conversion, EvidenceCodec}

defmodule QuoteRuntimeAssertions do
  def assert!(true, _message), do: :ok
  def assert!(_, message), do: raise("quote runtime assertion failed: #{message}")
end

QuoteRuntimeAssertions.assert!(Repo.query!("SELECT 1").rows == [[1]], "PostgreSQL readiness")

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

Code.ensure_loaded!(EvidenceCodec)

QuoteRuntimeAssertions.assert!(
  function_exported?(EvidenceCodec, :decode_facts, 1),
  "typed evidence decoder exists"
)

%{rows: [[orphaned]]} =
  Repo.query!("""
  SELECT count(*)
  FROM market_quotes q
  LEFT JOIN quote_evaluation_requests e ON e.quote_id=q.id
  WHERE q.calculation_id IS NOT NULL AND e.id IS NULL
  """)

QuoteRuntimeAssertions.assert!(
  orphaned == 0,
  "every committed performance quote has follow-up work"
)

%{rows: [[broken_issuances]]} =
  Repo.query!("""
  SELECT count(*) FROM (
    SELECT i.player_id
    FROM market_issuances i
    JOIN market_quotes q ON q.id=i.initial_quote_id
    LEFT JOIN market_holdings h ON h.player_id=i.player_id
    GROUP BY i.player_id, q.id
    HAVING q.rule_id <> 'initial_issuance' OR q.unit_price <> 1 OR coalesce(sum(h.quantity), 0) <> 100
  ) broken
  """)

QuoteRuntimeAssertions.assert!(
  broken_issuances == 0,
  "initial quote and 100-unit holdings remain intact"
)

schema_names =
  Repo.query!("""
  SELECT n.nspname
  FROM pg_namespace n
  JOIN pg_class c ON c.relnamespace=n.oid
  WHERE n.nspname LIKE 'valuation_test_%' AND c.relname='quote_calculations'
  ORDER BY n.nspname DESC
  """).rows
  |> Enum.map(fn [name] -> name end)

schema =
  Enum.find(schema_names, fn candidate ->
    Regex.match?(~r/^valuation_test_[a-f0-9]+$/, candidate) and
      Repo.query!(
        "SELECT count(*) FROM #{candidate}.quote_calculations WHERE status='successful'",
        []
      ).rows != [[0]]
  end)

QuoteRuntimeAssertions.assert!(is_binary(schema), "integration persisted a replay fixture")

calculation_id =
  Repo.query!(
    "SELECT id FROM #{schema}.quote_calculations WHERE status='successful' ORDER BY inserted_at DESC LIMIT 1"
  ).rows
  |> hd()
  |> hd()
  |> Ecto.UUID.load!()

Code.require_file("test/support/quotes/runtime_probe.ex")

intent_id = Ecto.UUID.generate()

producer_process = """
alias FootballMarket.{Repo, Quotes}
alias FootballMarket.Quotes.Calculation
alias FootballMarket.Statistics.Ingestion.{CalculationIntent, Check}
schema = System.fetch_env!("QUOTE_SCHEMA")
{:ok, client} = Repo.start_link(name: nil, pool: DBConnection.ConnectionPool, pool_size: 3, parameters: [search_path: schema])
Repo.put_dynamic_repo(client)
calculation_id = System.fetch_env!("QUOTE_CALCULATION_ID")
intent_id = System.fetch_env!("QUOTE_INTENT_ID")
calculation = Repo.get!(Calculation, calculation_id)
now = DateTime.utc_now() |> DateTime.truncate(:microsecond)
scope_id = Ecto.UUID.generate()
run_id = Ecto.UUID.generate()
attempt_id = Ecto.UUID.generate()
check_id = Ecto.UUID.generate()
delivery_id = Ecto.UUID.generate()
{league_code, start_year, end_year} = Repo.query!("SELECT l.code, s.start_year, s.end_year FROM seasons s JOIN leagues l ON l.id=s.league_id WHERE s.id=$1", [Ecto.UUID.dump!(calculation.season_id)]).rows |> hd() |> then(fn [league, start_year, end_year] -> {league, start_year, end_year} end)
Repo.query!("INSERT INTO statistics_import_scopes (id,provider,identity_namespace,league_code,start_year,end_year,season_id) VALUES ($1,'fixture','quote-runtime',$2,$3,$4,$5)", [Ecto.UUID.dump!(scope_id), league_code, start_year, end_year, Ecto.UUID.dump!(calculation.season_id)])
Repo.query!("INSERT INTO synchronization_runs (id,league_code,start_year,end_year,source_ref,input,input_digest,policy,original_trigger,state,requested_at) VALUES ($1,$2,$3,$4,'quote-runtime',$5,'quote-runtime',$6,'manual','succeeded',$7)", [Ecto.UUID.dump!(run_id), league_code, start_year, end_year, %{"version" => 1}, %{"attempt_limit" => 1}, now])
Repo.query!("INSERT INTO synchronization_attempts (id,run_id,number,delivery_id,started_at,status) VALUES ($1,$2,1,$3,$4,'succeeded')", [Ecto.UUID.dump!(attempt_id), Ecto.UUID.dump!(run_id), Ecto.UUID.dump!(delivery_id), now])
Repo.query!("INSERT INTO statistics_import_checks (id,scope_id,run_id,attempt_id,accepted_at,retrieved_at,evidence_version,evidence,outcome,canonical_digest,canonical_material,changed_matches,changed_performances) VALUES ($1,$2,$3,$4,$5,$5,1,'{}','accepted_changes','quote-runtime','{}',0,$6)", [Ecto.UUID.dump!(check_id), Ecto.UUID.dump!(scope_id), Ecto.UUID.dump!(run_id), Ecto.UUID.dump!(attempt_id), now, length(calculation.membership)])
intent = Repo.insert!(%CalculationIntent{id: intent_id, accepted_check_id: check_id, changed_performance_ids: calculation.membership, requested_at: now})
:ok = Quotes.Membership.snapshot_import!(intent.id, intent.changed_performance_ids)
Application.put_env(:football_market, :quote_mapping_id, calculation.mapping_id)
{:ok, _active_configuration} = FootballMarket.Valuation.Configurations.activate(calculation.configuration_version_id, nil)
{:ok, _receiving} = FootballMarket.Valuation.CalculationRequests.accept(intent.id, check_id, calculation.membership)
request = Repo.get_by!(FootballMarket.Quotes.CalculationRequest, intent_id: intent.id)
true = request.state == "pending"
IO.puts("QUOTE_IMPORT_PINNED=" <> intent.id)
"""

producer_output =
  FootballMarket.Quotes.RuntimeProbe.fresh_beam!(producer_process, [
    {"QUOTE_SCHEMA", schema},
    {"QUOTE_CALCULATION_ID", calculation_id},
    {"QUOTE_INTENT_ID", intent_id}
  ])

QuoteRuntimeAssertions.assert!(
  producer_output =~ "QUOTE_IMPORT_PINNED=" <> intent_id,
  "accepted import pins complete membership before dispatch"
)

{:ok, request_id} =
  Repo.query!("SELECT id FROM quote_calculation_requests WHERE intent_id=$1", [
    Ecto.UUID.dump!(intent_id)
  ]).rows
  |> hd()
  |> hd()
  |> Ecto.UUID.load()

recovery_process = """
alias FootballMarket.{Repo, Quotes}
schema = System.fetch_env!("QUOTE_SCHEMA")
{:ok, client} = Repo.start_link(name: nil, pool: DBConnection.ConnectionPool, pool_size: 3, parameters: [search_path: schema])
Repo.put_dynamic_repo(client)
request_id = System.fetch_env!("QUOTE_REQUEST_ID")
{:ok, recovered} = Quotes.Recovery.recover_pending()
true = recovered >= 1
:ok = Quotes.process_import_request(request_id)
request = Repo.get!(FootballMarket.Quotes.CalculationRequest, request_id)
true = request.state == "successful"
IO.puts("QUOTE_IMPORT_RECOVERED=" <> request_id)
"""

recovery_output =
  FootballMarket.Quotes.RuntimeProbe.fresh_beam!(recovery_process, [
    {"QUOTE_SCHEMA", schema},
    {"QUOTE_REQUEST_ID", request_id}
  ])

QuoteRuntimeAssertions.assert!(
  recovery_output =~ "QUOTE_IMPORT_RECOVERED=" <> request_id,
  "fresh process recovers and confirms quote calculation"
)

fresh_process = """
import Ecto.Query

alias FootballMarket.{Repo, Quotes}
alias FootballMarket.Quotes.{Calculation, CalculationRequest, Evaluation, EvidenceCodec}
schema = System.fetch_env!("QUOTE_SCHEMA")
true = Regex.match?(~r/^valuation_test_[a-f0-9]+$/, schema)
{:ok, client} = Repo.start_link(name: nil, pool: DBConnection.ConnectionPool, pool_size: 3, parameters: [search_path: schema])
Repo.put_dynamic_repo(client)
calculation_id = System.fetch_env!("QUOTE_CALCULATION_ID")
{:ok, replay} = Quotes.replay(calculation_id)
%Calculation{} = calculation = replay.calculation
true = calculation.status == "successful"
true = is_binary(calculation.configuration_version_id) and is_binary(calculation.mapping_id)
true = Decimal.equal?(replay.score, calculation.score)
true = Decimal.equal?(replay.outcome.price, calculation.unit_price)
true = calculation.evidence["configuration_version_id"] == calculation.configuration_version_id
true = calculation.evidence["mapping_id"] == calculation.mapping_id
{:ok, facts} = EvidenceCodec.decode_facts(calculation.evidence["facts"])
true = Enum.map(facts, & &1.performance_id) == calculation.membership
{:ok, mapping} = Quotes.get_mapping(calculation.mapping_id)
true = calculation.evidence["scale"] == Decimal.to_string(mapping.scale)
{:ok, %{rows: [[1, quote_configuration_id, quote_mapping_id]]}} = Repo.query("SELECT (SELECT count(*) FROM market_quotes WHERE calculation_id=$1), configuration_version_id, mapping_id FROM market_quotes WHERE calculation_id=$1", [Ecto.UUID.dump!(calculation_id)])
true = Ecto.UUID.load!(quote_configuration_id) == calculation.configuration_version_id
true = Ecto.UUID.load!(quote_mapping_id) == calculation.mapping_id
{:ok, %{rows: [[1, idempotency_key]]}} = Repo.query("SELECT count(*), min(idempotency_key) FROM quote_evaluation_requests WHERE calculation_id=$1", [Ecto.UUID.dump!(calculation_id)])
true = idempotency_key == "quote-evaluation:" <> Ecto.UUID.load!(Repo.query!("SELECT quote_id FROM quote_evaluation_requests WHERE calculation_id=$1", [Ecto.UUID.dump!(calculation_id)]).rows |> hd() |> hd())
{:ok, %{rows: [[initial_quote, initial_rule, holdings]]}} = Repo.query("SELECT q.unit_price, q.rule_id, (SELECT coalesce(sum(quantity),0) FROM market_holdings WHERE player_id=$1) FROM market_issuances i JOIN market_quotes q ON q.id=i.initial_quote_id WHERE i.player_id=$1", [Ecto.UUID.dump!(calculation.player_id)])
true = Decimal.equal?(initial_quote, Decimal.new(1)) and initial_rule == "initial_issuance" and holdings == 100
{:ok, request} = Repo.one(from(r in CalculationRequest, where: r.calculation_id == ^calculation_id and r.source == "explicit")) |> then(fn row -> if row, do: {:ok, row}, else: {:error, :missing_request} end)
selector = if request.selector == "active", do: :active, else: {:version, String.replace_prefix(request.selector, "version:", "")}
before = Repo.query!("SELECT (SELECT count(*) FROM market_quotes WHERE calculation_id=$1), (SELECT count(*) FROM quote_evaluation_requests WHERE calculation_id=$1)", [Ecto.UUID.dump!(calculation_id)]).rows
{:ok, retried} = Quotes.request(%{player_id: calculation.player_id, season_id: calculation.season_id, week_start: calculation.week_start, week_end: calculation.week_end}, selector, calculation.mapping_id, request.id)
true = retried.calculation.id == calculation.id
after_retry = Repo.query!("SELECT (SELECT count(*) FROM market_quotes WHERE calculation_id=$1), (SELECT count(*) FROM quote_evaluation_requests WHERE calculation_id=$1)", [Ecto.UUID.dump!(calculation_id)]).rows
true = before == after_retry
IO.puts("QUOTE_FRESH_BEAM_PASS")
"""

fresh_output =
  FootballMarket.Quotes.RuntimeProbe.fresh_beam!(fresh_process, [
    {"QUOTE_SCHEMA", schema},
    {"QUOTE_CALCULATION_ID", calculation_id}
  ])

QuoteRuntimeAssertions.assert!(
  fresh_output =~ "QUOTE_FRESH_BEAM_PASS",
  "fresh application can replay persisted evidence"
)

QuoteRuntimeAssertions.assert!(
  Repo.query!(
    "SELECT count(*) FROM quote_calculation_requests WHERE id=$1 AND state='successful'",
    [Ecto.UUID.dump!(request_id)]
  ).rows == [[1]],
  "recovered import has a successful independent calculation status"
)

QuoteRuntimeAssertions.assert!(
  Repo.query!("SELECT count(*) FROM quote_import_scope_snapshots WHERE intent_id=$1", [
    Ecto.UUID.dump!(intent_id)
  ]).rows == [[1]],
  "accepted import snapshot remains durable"
)

IO.puts("QUOTE_RUNTIME_ASSERTIONS_PASS")
