defmodule Task026IndependentAdmissionQA do
  use FootballMarket.DataCase, async: false
  alias FootballMarket.{Quotes, Repo, QuotesCase, ValuationConfigurationCase}
  alias FootballMarket.Valuation.Configurations

  setup do
    ValuationConfigurationCase.private_schema()
    {:ok, QuotesCase.fixture()}
  end

  test "missing mapping UUID leaves a durable terminal admission", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    id = Ecto.UUID.generate()
    result = Quotes.request(f.subject, :active, Ecto.UUID.generate(), id)
    row = Quotes.get_request(id)
    IO.inspect({result, row}, label: "QA_MISSING_MAPPING")
    assert {:ok, %{state: "validation_failed", reason: "mapping_unavailable"}} = row
  end

  test "retry of terminal missing selection returns the retained terminal outcome", f do
    id = Ecto.UUID.generate()
    assert {:error, :configuration_unavailable} = Quotes.request(f.subject, :active, f.mapping.id, id)
    assert {:ok, %{state: "validation_failed"}} = Quotes.get_request(id)
    result = Quotes.request(f.subject, :active, f.mapping.id, id)
    IO.inspect(result, label: "QA_TERMINAL_RETRY")
    assert {:error, :configuration_unavailable} = result
  end

  test "successful terminal request cannot be overwritten after replay failure", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    id = Ecto.UUID.generate()
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id, id)
    request = Repo.get!(FootballMarket.Quotes.CalculationRequest, id)
    assert_raise Postgrex.Error, fn ->
      Repo.update!(Ecto.Changeset.change(request, state: "pending", calculation_id: nil))
    end
  end
end
