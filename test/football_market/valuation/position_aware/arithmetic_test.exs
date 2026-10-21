defmodule FootballMarket.Valuation.PositionAware.ArithmeticTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase, only: [fixture: 0, record: 3]
  import FootballMarket.PositionAwareCase

  test "US4.1 US4.2 US4.3 US4.8 US4.9 independent rational vectors under three Decimal contexts" do
    f = fixture()
    p = position()
    counts = %{goals: 1, assists: 1, tackles: 1}
    record(f, "defender", counts)
    record(f, "forward", Map.put(counts, :position_id, p.id))
    counts_by_group = %{defender: counts, forward: counts}
    rows = vectors()
    summary = oracle_summary(rows, counts_by_group)
    assert summary.count == 78

    assert Enum.map(Enum.take(rows, 18), fn {weights, refs} ->
             oracle(weights, counts_by_group, refs)
           end) == [
             "0.000000",
             "0.000000",
             "0.000001",
             "0.500001",
             "0.007813",
             "0.000000",
             "1.000000",
             "1.000000",
             "-0.000001",
             "-0.000001",
             "-0.000001",
             "-0.000001",
             "0.000000",
             "0.000001",
             "0.000001",
             "0.000001",
             "0.000001",
             "0.000000"
           ]

    IO.puts("POSITION_ORACLE count=#{summary.count} contexts=3 checksum=#{summary.checksum}")
    original = Decimal.Context.get()

    try do
      retained =
        for {precision, rounding} <- [{1, :down}, {3, :ceiling}, {100, :half_even}] do
          Decimal.Context.set(%{original | precision: precision, rounding: rounding})

          for {weights, references} <- rows do
            r =
              calculate(f, definition(weights), references, %{
                position_mapping: [{f.position.id, :defender}, {p.id, :forward}]
              })

            assert r.score == oracle(weights, counts_by_group, references)
            assert r.score =~ ~r/^-?\d+\.\d{6}$/
            refute r.score == "-0.000000"

            for {g, metrics} <- r.prepared.request.requirements,
                g in [:defender, :forward],
                m <- metrics do
              assert r.prepared.scopes[g].features[m] ==
                       fixed(feature_units(counts[m], references[m]))
            end

            {r, definition(weights)}
          end
        end

      record(f, "late-defender", counts)

      for {r, d} <- List.flatten(retained),
          do: assert({:ok, r} == FootballMarket.Valuation.replay(r.descriptor, d))
    after
      Decimal.Context.set(original)
    end

    assert oracle(elem(Enum.at(rows, 3), 0), counts_by_group, %{goals: 6}) == "0.500001"
    assert oracle(elem(Enum.at(rows, 4), 0), counts_by_group, %{goals: 128}) == "0.007813"
  end

  test "zero factors tolerate wide finite exponents and fractional references" do
    f = fixture()
    record(f, "zero", %{goals: 0})

    for exp <- [-10_000, 10_000], sign <- [-1, 1] do
      r =
        calculate(f, definition(rules(%{goals: %Decimal{sign: sign, coef: 1, exp: exp}})), %{
          goals: Decimal.new("0.125")
        })

      assert r.score == "0.000000"
    end
  end
end
