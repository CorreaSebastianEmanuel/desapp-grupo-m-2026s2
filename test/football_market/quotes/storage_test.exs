defmodule FootballMarket.Quotes.StorageTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, Repo}
  alias FootballMarket.QuotesCase
  alias FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations

  setup do
    ValuationConfigurationCase.private_schema()
    {:ok, QuotesCase.fixture()}
  end

  test "saved mappings and terminal calculation evidence reject direct mutation", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, %{calculation: calculation}} = Quotes.request(f.subject, :active, f.mapping.id)

    assert_raise Postgrex.Error, fn ->
      Repo.query!("UPDATE quote_conversion_mappings SET scale=2 WHERE id=$1", [
        Ecto.UUID.dump!(f.mapping.id)
      ])
    end

    assert_raise Postgrex.Error, fn ->
      Repo.query!("DELETE FROM quote_calculations WHERE id=$1", [Ecto.UUID.dump!(calculation.id)])
    end

    assert {:ok, retained} = Quotes.get_calculation(calculation.id)
    assert retained.evidence == calculation.evidence
  end
end
