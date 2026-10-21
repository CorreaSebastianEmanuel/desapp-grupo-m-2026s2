defmodule FootballMarket.Quotes.AdmissionTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, QuotesCase, Repo, ValuationConfigurationCase}

  setup do
    ValuationConfigurationCase.private_schema()
    {:ok, QuotesCase.fixture()}
  end

  test "a missing mapping is durably recorded and an identical retry returns it", fixture do
    request_id = Ecto.UUID.generate()
    missing_mapping_id = Ecto.UUID.generate()

    assert {:error, :mapping_unavailable} =
             Quotes.request(fixture.subject, :active, missing_mapping_id, request_id)

    assert {:ok, request} = Quotes.get_request(request_id)
    assert request.state == "validation_failed"
    assert request.reason == "mapping_unavailable"
    assert request.mapping_id == nil
    # The supplied unavailable identity stays inspectable in the persisted row.
    assert request.requested_mapping_id == missing_mapping_id

    assert {:error, :mapping_unavailable} =
             Quotes.request(fixture.subject, :active, missing_mapping_id, request_id)

    assert {:ok, retried} = Quotes.get_request(request_id)
    assert retried.id == request.id
    assert Repo.aggregate(FootballMarket.Quotes.CalculationRequest, :count, :id) == 1

    # Reused request_id with different mapping identity returns request_conflict.
    assert {:error, :request_conflict} =
             Quotes.request(fixture.subject, :active, fixture.mapping.id, request_id)

    # A different unavailable mapping UUID is also an identity conflict, and
    # the stored identity is not overwritten by the caller's alternate UUID.
    other_missing_mapping_id = Ecto.UUID.generate()

    assert {:error, :request_conflict} =
             Quotes.request(fixture.subject, :active, other_missing_mapping_id, request_id)

    assert {:ok, preserved} = Quotes.get_request(request_id)
    assert preserved.requested_mapping_id == missing_mapping_id
    assert Repo.aggregate(FootballMarket.Quotes.CalculationRequest, :count, :id) == 1
  end
end
