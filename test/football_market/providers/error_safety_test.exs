defmodule FootballMarket.Providers.ErrorSafetyTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Providers.{Error, Request}

  test "F-E01 all eight safe categories and retry guidance" do
    {:ok, request} =
      Request.normalize(:catalog, %{league_code: "PL", start_year: 2025, end_year: 2026})

    assert length(Error.categories()) == 8

    for category <- Error.categories() do
      error = Error.failure(%{category: category}, request)
      assert error.category == category
      assert error.retryable == category in [:rate_limited, :unavailable, :timeout]
      assert error.scope == request.scope and error.operation == :catalog
      assert error.retry_after_ms == nil
      refute Map.has_key?(error, :facts)
      refute Map.has_key?(error, :provenance)
    end
  end

  test "F-E02 optional rate limit delay is neither invented nor repaired" do
    {:ok, request} =
      Request.normalize(:catalog, %{league_code: "PL", start_year: 2025, end_year: 2026})

    for delay <- [nil, 7] do
      assert Error.failure(%{category: :rate_limited, retry_after_ms: delay}, request).retry_after_ms ==
               delay
    end

    for delay <- [0, -1, true, 1.5, "7"] do
      assert Error.failure(%{category: :rate_limited, retry_after_ms: delay}, request).category ==
               :invalid_response
    end

    assert Error.failure(%{category: :not_found, retry_after_ms: 7}, request).category ==
             :invalid_response

    assert Error.failure(%{category: :vendor_status, message: "FAKE_SENTINEL"}, request).category ==
             :invalid_response
  end

  def provider_label, do: Process.get(:hostile_provider_label, "safe-source")

  def read(request, context, state) do
    case state do
      {:failure, failure} ->
        {:error, failure}

      :exception ->
        raise "Authorization: Bearer FAKE_SENTINEL"

      {:candidate, mutate} ->
        {:ok, candidate} =
          FootballMarket.Providers.FixtureSourceA.read(request, context, "F-C01-PL-2025-2026-A")

        {:ok, mutate.(candidate)}
    end
  end

  test "F-E01 through F-E03 every complete outcome is safe against both sources" do
    alias FootballMarket.ProviderContractCase, as: Contract

    for id <- Contract.ids("F-E"),
        adapter <- [
          FootballMarket.Providers.FixtureSourceA,
          FootballMarket.Providers.FixtureSourceB
        ],
        do: Contract.assert_contract!(adapter, id)
  end

  test "F-E03 hostile labels, source IDs/refs, diagnostics, malformed shapes and exceptions" do
    alias FootballMarket.Providers.{FixtureRuntime, Provenance}
    request = %{league_code: "PL", start_year: 2025, end_year: 2026}

    call = fn state ->
      Process.put(:fixture_elapsed, 0)

      FootballMarket.Providers.catalog(request,
        provider: {__MODULE__, state},
        positions: %{"FW" => "Forward", "GK" => "Goalkeeper"},
        runtime: {FixtureRuntime, %{}}
      )
    end

    hostile = [
      "https://FAKE_SENTINEL.invalid",
      "https://FAKE_SENTINEL:pw@invalid",
      "https://invalid/?token=FAKE_SENTINEL",
      "Authorization: Bearer FAKE_SENTINEL",
      "Basic FAKE_SENTINEL",
      "token=FAKE_SENTINEL",
      "safe\nFAKE_SENTINEL",
      "safe\u0085FAKE_SENTINEL",
      "safe\u202eFAKE_SENTINEL",
      <<255>>
    ]

    for value <- hostile do
      refute Provenance.safe_text?(value)
      Process.put(:hostile_provider_label, value)
      assert {:error, error} = call.(:exception)
      assert error.category == :invalid_response
      refute inspect(error) =~ "FAKE_SENTINEL"
      Process.delete(:hostile_provider_label)

      for mutate <- [
            fn c -> put_in(c, [:fixture_id], value) end,
            fn c ->
              update_in(c, [:bindings], fn [b | rest] -> [%{b | source_id: value} | rest] end)
            end,
            fn c -> put_in(c, [:facts, :league, :ref], value) end
          ] do
        assert {:error, error} = call.({:candidate, mutate})
        assert error.category == :invalid_response
        refute inspect(error) =~ "FAKE_SENTINEL"
      end
    end

    assert {:error, error} = call.(:exception)
    assert error.category == :unavailable

    for failure <- [
          %{category: :unavailable, headers: "FAKE_SENTINEL"},
          %{category: "FAKE_SENTINEL"},
          nil,
          []
        ] do
      assert {:error, error} = call.({:failure, failure})
      assert error.category == :invalid_response
      refute inspect(error) =~ "FAKE_SENTINEL"
    end
  end
end
