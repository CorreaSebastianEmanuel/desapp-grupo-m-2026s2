defmodule FootballMarket.Providers.RequestTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Providers.Request

  test "F-R01 fixed key formats, all leagues, years and default timeout" do
    for league <- ["PL", "BL1", "PD", "SA", "FL1"], y <- [2024, 2025], ending <- [y, y + 1] do
      input = %{league_code: " #{String.downcase(league)} ", start_year: y, end_year: ending}

      for request <- [input, Map.new(input, fn {k, v} -> {Atom.to_string(k), v} end)] do
        assert {:ok, normalized} = Request.normalize(:catalog, request)
        assert normalized.scope == %{league_code: league, start_year: y, end_year: ending}
        assert normalized.timeout_ms == 5000
      end
    end
  end

  test "F-R02 every invalid input is rejected before provider work" do
    base = %{league_code: "PL", start_year: 2025, end_year: 2026}

    invalid =
      [
        nil,
        [],
        Map.delete(base, :league_code),
        Map.put(base, "to", nil),
        Map.put(base, :from, nil),
        Map.put(base, :alien, "FAKE_SENTINEL"),
        Map.put(base, :league_code, "ZZ"),
        Map.put(base, :end_year, 2028)
      ] ++
        for(
          key <- [:start_year, :end_year, :timeout_ms],
          value <- [nil, false, true, 1.5, "2025"],
          do: Map.put(base, key, value)
        ) ++
        for(value <- [0, -1], do: Map.put(base, :timeout_ms, value))

    for input <- invalid do
      assert {:error, error} =
               FootballMarket.Providers.catalog(input, provider: {__MODULE__, self()})

      assert error.category == :invalid_request
      refute inspect(error) =~ "FAKE_SENTINEL"
      refute_receive :provider_work
    end
  end

  test "F-R02 invalid timeout retains independently validated scope in both operations" do
    base = %{league_code: " pl ", start_year: 2025, end_year: 2026}
    scope = %{league_code: "PL", start_year: 2025, end_year: 2026}

    for operation <- [:catalog, :performances],
        timeout <- [0, -1, nil, true, false, 1.5, "7", %{}],
        string_keys <- [false, true] do
      input = Map.put(base, :timeout_ms, timeout)

      input =
        if string_keys, do: Map.new(input, fn {k, v} -> {Atom.to_string(k), v} end), else: input

      assert {:error, error} =
               apply(FootballMarket.Providers, operation, [
                 input,
                 [provider: {__MODULE__, self()}]
               ])

      assert error.category == :invalid_request
      assert error.operation == operation
      assert error.field == :timeout_ms

      expected =
        if operation == :catalog, do: scope, else: Map.merge(scope, %{from: nil, to: nil})

      assert error.scope == expected
      refute_receive :provider_work, 0
    end

    assert {:error, error} =
             FootballMarket.Providers.performances(
               Map.merge(base, %{timeout_ms: 0, from: "2025-01-01T01:00:00+01:00"})
             )

    assert error.scope == Map.merge(scope, %{from: ~U[2025-01-01 00:00:00.000000Z], to: nil})

    for operation <- [:catalog, :performances],
        malformed <- [
          Map.put(base, :league_code, "FAKE_SENTINEL"),
          Map.put(base, :start_year, true),
          Map.put(base, :end_year, 2028),
          Map.delete(base, :end_year)
        ] do
      assert {:error, error} =
               apply(FootballMarket.Providers, operation, [
                 Map.put(malformed, :timeout_ms, 0),
                 [provider: {__MODULE__, self()}]
               ])

      assert error.category == :invalid_request
      assert error.scope == nil
      refute inspect(error) =~ "FAKE_SENTINEL"
      refute_receive :provider_work, 0
    end

    assert {:error, error} =
             FootballMarket.Providers.performances(
               Map.merge(base, %{timeout_ms: 0, from: "FAKE_SENTINEL"})
             )

    assert error.scope == nil
    refute inspect(error) =~ "FAKE_SENTINEL"
  end

  def provider_label, do: "spy"

  def read(_, _, pid) do
    send(pid, :provider_work)
    {:error, %{category: :not_found}}
  end

  test "F-R03 inclusive independent bounds, equal offsets and custom budget" do
    base = %{league_code: "PL", start_year: 2025, end_year: 2025, timeout_ms: 7}

    for bounds <- [
          %{},
          %{from: "2025-01-01T01:00:00+01:00"},
          %{to: "2025-01-01T00:00:00Z"},
          %{from: "2025-01-01T01:00:00+01:00", to: "2025-01-01T00:00:00Z"}
        ] do
      assert {:ok, request} = Request.normalize(:performances, Map.merge(base, bounds))
      assert request.timeout_ms == 7
      assert Map.has_key?(request.scope, :from) and Map.has_key?(request.scope, :to)
    end
  end

  test "F-R04 no naive, invalid, lossy or reversed instants; unknown keys create no atoms" do
    base = %{league_code: "PL", start_year: 2025, end_year: 2026}

    for value <- [~N[2025-01-01 00:00:00], "2025-01-01", "2025-01-01T00:00:00.1234567Z", false] do
      assert {:error, _} = Request.normalize(:performances, Map.put(base, :from, value))
    end

    assert {:error, _} =
             Request.normalize(
               :performances,
               Map.merge(base, %{from: "2025-02-01T00:00:00Z", to: "2025-01-01T00:00:00Z"})
             )

    key = "unknown_provider_key_#{System.unique_integer([:positive])}"
    assert {:error, _} = Request.normalize(:catalog, Map.put(base, key, "FAKE_SENTINEL"))
    assert_raise ArgumentError, fn -> String.to_existing_atom(key) end
  end

  test "malformed DateTime structures and invalid trusted vocabulary fail before callbacks" do
    base = %{league_code: "PL", start_year: 2025, end_year: 2026}

    for dt <- [
          %{~U[2025-01-01 00:00:00Z] | microsecond: {0, 7}},
          %{~U[2025-01-01 00:00:00Z] | time_zone: nil},
          %{~U[2025-01-01 00:00:00Z] | year: 0}
        ] do
      assert {:error, _} = Request.normalize(:performances, Map.put(base, :from, dt))
    end

    for vocabulary <- [
          nil,
          %{},
          %{"FW" => "Forward", "fw" => "Other"},
          %{"FW" => "https://FAKE_SENTINEL.invalid"}
        ] do
      assert {:error, error} =
               FootballMarket.Providers.catalog(base,
                 provider: {__MODULE__, self()},
                 positions: vocabulary
               )

      assert error.category == :invalid_request and error.field == :positions
      refute inspect(error) =~ "FAKE_SENTINEL"
      refute_receive :provider_work
    end

    assert {:error, error} = FootballMarket.Providers.catalog(base, provider: nil)
    assert error.category == :unsupported_capability
  end
end
