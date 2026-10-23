defmodule Task026QAConflictTest do
  use FootballMarket.DataCase, async: false
  alias FootballMarket.{Quotes, QuotesCase, ValuationConfigurationCase}
  test "terminal admission still rejects conflicting request identity" do
    ValuationConfigurationCase.private_schema()
    f = QuotesCase.fixture()
    request = Ecto.UUID.generate()
    missing = Ecto.UUID.generate()
    assert {:error, :mapping_unavailable} = Quotes.request(f.subject, :active, missing, request)
    assert {:error, :request_conflict} = Quotes.request(f.subject, {:version, f.configuration.id}, f.mapping.id, request)
  end
end
