"""QA-owned Fraction oracle; writes bulk cases only to /tmp, never to the repo."""
from datetime import datetime, timedelta
from fractions import Fraction
import hashlib
import json
from pathlib import Path
import random

GROUPS = ['goalkeeper', 'defender', 'midfielder', 'forward']
METRICS = ['goals', 'assists', 'shots_on_target', 'tackles', 'interceptions',
           'saves', 'goals_conceded', 'yellow_cards', 'red_cards']

def round_units(value):
    scaled = abs(value) * 1_000_000
    quotient, remainder = divmod(scaled.numerator, scaled.denominator)
    units = quotient + (2 * remainder >= scaled.denominator)
    return -units if value < 0 else units

def fixed(units):
    return ('-' if units < 0 else '') + str(abs(units) // 1_000_000) + '.' + str(abs(units) % 1_000_000).zfill(6)

def elixir(value):
    if isinstance(value, dict):
        return '%{' + ', '.join(':' + k + ' => ' + elixir(v) for k, v in value.items()) + '}'
    if isinstance(value, list):
        return '[' + ', '.join(elixir(v) for v in value) + ']'
    if isinstance(value, str):
        return json.dumps(value)
    return str(value)

rng = random.Random(2406013)
cases = []
for n in range(32):
    refs = {m: str(rng.randrange(1, 200)) + 'E-1' for m in METRICS}
    weights, counts, expected_features = {}, {}, {}
    total = Fraction(0)
    for g in GROUPS:
        metrics = rng.sample(METRICS, rng.randrange(1, 10))
        weights[g] = {m: str(rng.randrange(-100, 101)) + 'E' + str(rng.choice([-8, -6, -3, 0, 32])) for m in metrics}
        rows = [{m: rng.randrange(0, 8) for m in METRICS} for _ in range(2)]
        if n == 31:
            rows[0] = {m: 10 ** 40 for m in METRICS}
        counts[g] = rows
        expected_features[g] = {}
        for m, weight in weights[g].items():
            feature = round_units(min(Fraction(sum(row[m] for row in rows)) / Fraction(refs[m]), Fraction(1)))
            expected_features[g][m] = fixed(feature)
            total += Fraction(feature, 1_000_000) * Fraction(weight)
    start = datetime(2026, 10, 5) + timedelta(weeks=n)
    cases.append({'weights': weights, 'references': refs, 'rows': counts,
                  'features': expected_features, 'score': fixed(round_units(total)),
                  'opening': start.strftime('%Y-%m-%dT00:00:00Z'),
                  'closing': (start + timedelta(days=7)).strftime('%Y-%m-%dT00:00:00Z'),
                  'kickoff': start.strftime('%Y-%m-%dT12:00:00Z')})
checksum = hashlib.sha256(json.dumps(cases, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
source = '''defmodule IndependentPositionAwareQA do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.PositionAwareCase
  test "independent Python fractions cover four populated roles with signed weights" do
    f = FootballMarket.ValuationCase.fixture()
    positions = Map.new(groups(), &{&1, position().id})
    original = Decimal.Context.get()
    try do
      Decimal.Context.set(%{original | precision: 1, rounding: :down})
      for {v, index} <- Enum.with_index(CASES) do
        for g <- groups(), {counts, row} <- Enum.with_index(v.rows[g]) do
          FootballMarket.ValuationCase.record(f, "qa-#{index}-#{g}-#{row}",
            Map.merge(counts, %{position_id: positions[g], minutes_played: if(row == 0, do: 0, else: 130)}), v.kickoff)
        end
        weights = Map.new(v.weights, fn {g, entries} -> {g, Map.new(entries, fn {m, w} -> {m, Decimal.new(w)} end)} end)
        references = Map.new(v.references, fn {m, r} -> {m, Decimal.new(r)} end)
        configured = weights |> Map.values() |> Enum.flat_map(&Map.keys/1) |> Enum.uniq()
        references = Map.take(references, configured)
        result = calculate(f, definition(weights), references,
          %{week_start: v.opening, week_end: v.closing, position_mapping: Map.to_list(positions) |> Enum.map(fn {g, id} -> {id, g} end)})
        assert result.score == v.score
        assert length(result.prepared.facts) == 8
        for g <- groups() do
          assert result.prepared.scopes[g].features == v.features[g]
          assert result.prepared.scopes[g].row_count == 2
        end
      end
      IO.puts("QA_FRACTION_ORACLE count=32 groups=4 facts=256 checksum=CHECKSUM")
    after
      Decimal.Context.set(original)
    end
  end
end
'''.replace('CASES', elixir(cases)).replace('CHECKSUM', checksum)
target = Path('/tmp/task024_fraction_probe_test.exs')
target.write_text(source)
print('QA_FRACTION_GENERATOR count=32 checksum=' + checksum + ' target=' + str(target))
