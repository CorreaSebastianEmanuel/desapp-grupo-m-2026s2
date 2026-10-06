defmodule FootballMarket.ProviderContractCase do
  @moduledoc "Reusable deterministic acceptance against independent declared expectations."
  import ExUnit.Assertions
  alias FootballMarket.Providers
  alias FootballMarket.Providers.{FactOracle, FixtureRuntime}
  @external_resource "test/fixtures/providers/cases.exs"
  @external_resource "test/fixtures/providers/expected.exs"
  @cases "test/fixtures/providers/cases.exs" |> Code.eval_file() |> elem(0)
  @expected_binary "test/fixtures/providers/expected.exs"
                   |> Code.eval_file()
                   |> elem(0)
                   |> :erlang.term_to_binary()
  def cases, do: @cases
  def expected, do: :erlang.binary_to_term(@expected_binary)

  def ids(prefixes) do
    ids =
      for c <- @cases, Enum.any?(List.wrap(prefixes), &String.starts_with?(c.id, &1)), do: c.id

    assert ids != []
    ids
  end

  def assert_contract!(adapter, id) do
    c = Enum.find(@cases, &(&1.id == id))
    assert c != nil
    Process.put(:fixture_elapsed, 0)

    options = [
      provider: {adapter, c.sources[adapter.source_key()]},
      positions: c.positions,
      runtime: {FixtureRuntime, %{validation_us: c.validation_us}}
    ]

    outcome = apply(Providers, c.operation, [c.request, options])
    expected = Map.fetch!(expected(), id)

    case expected do
      %{category: category} ->
        assert match?({:error, _}, outcome), "#{id} #{inspect(adapter)}: #{inspect(outcome)}"
        {:error, error} = outcome
        assert error.category == category
        assert public_scope(error.scope) == c.expected_scope
        assert error.retryable == category in [:rate_limited, :unavailable, :timeout]
        assert error.retry_after_ms == Map.get(expected, :retry_after_ms)
        refute inspect(error) =~ "FAKE_SENTINEL"

      %{facts: facts} ->
        assert match?({:ok, _}, outcome), "#{id} #{inspect(adapter)}: #{inspect(outcome)}"
        {:ok, result} = outcome
        assert result.operation == c.operation
        assert public_scope(result.scope) == c.expected_scope
        FactOracle.assert_facts!(result.facts, facts, c.correspondence[adapter.source_key()])
        assert result.provenance.provider == adapter.provider_label()
        assert result.provenance.fixture_id == id
        assert result.provenance.retrieved_at == ~U[2026-10-06 12:00:00.000000Z]

        actual =
          Enum.map(result.provenance.bindings, fn binding ->
            assert binding.provider == result.provenance.provider
            assert binding.league_code == result.scope.league_code
            assert binding.start_year == result.scope.start_year
            assert binding.end_year == result.scope.end_year
            Map.take(binding, [:kind, :ref, :source_id])
          end)

        assert Enum.sort(actual) == Enum.sort(c.expected_bindings[adapter.source_key()])
    end

    outcome
  end

  defp public_scope(nil), do: nil

  defp public_scope(scope),
    do:
      Map.new(scope, fn {k, v} ->
        {k, if(match?(%DateTime{}, v), do: DateTime.to_iso8601(v), else: v)}
      end)
end
