defmodule FootballMarket.Providers.DeadlineTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Providers
  alias FootballMarket.Providers.FixtureRuntime
  @request %{league_code: "PL", start_year: 2025, end_year: 2026}
  def provider_label, do: "timing"

  def read(_request, _context, {:delay, elapsed, owner}) do
    send(owner, :work)
    FixtureRuntime.advance(elapsed)
    {:error, %{category: :not_found}}
  end

  def read(_request, _context, {:blocked, owner}) do
    send(owner, {:worker, self()})

    receive do
      :never -> {:error, %{category: :not_found}}
    end
  end

  def read(_, _, {:immediate, owner}) do
    send(owner, :provider_work)
    {:error, %{category: :not_found}}
  end

  def read(_, _, :crash), do: exit({:raw_secret, "FAKE_SENTINEL"})

  test "F-D02 production runtime accepts budgets above the VM receive limit" do
    for operation <- [:catalog, :performances], timeout <- [4_294_968_000, 10_000_000_000_000] do
      request = Map.put(@request, :timeout_ms, timeout)

      expected_scope =
        if operation == :catalog, do: @request, else: Map.merge(@request, %{from: nil, to: nil})

      assert {:ok, normalized} = FootballMarket.Providers.Request.normalize(operation, request)
      assert normalized.timeout_ms == timeout

      assert {:error, error} =
               apply(Providers, operation, [
                 request,
                 [positions: %{"FW" => "Forward"}, provider: {__MODULE__, {:immediate, self()}}]
               ])

      assert error.category == :not_found
      assert error.scope == expected_scope
      assert_receive :provider_work

      fixture = if operation == :catalog, do: "F-C01-PL-2025-2026-A", else: "F-P08-transfer"

      assert {:ok, result} =
               apply(Providers, operation, [
                 request,
                 [
                   positions: %{"FW" => "Forward", "GK" => "Goalkeeper"},
                   provider: {FootballMarket.Providers.FixtureSourceA, fixture}
                 ]
               ])

      assert result.operation == operation
      assert result.scope == expected_scope
      assert result.facts.players != []
      refute_receive {:provider_ready, _, _, _}, 0
      refute_receive {:provider_timeout, _}, 0
    end
  end

  test "F-D05 huge production budget still cancels blocked work on caller exit" do
    owner = self()

    for operation <- [:catalog, :performances] do
      caller =
        spawn(fn ->
          apply(Providers, operation, [
            Map.put(@request, :timeout_ms, 10_000_000_000_000),
            [positions: %{"FW" => "Forward"}, provider: {__MODULE__, {:blocked, owner}}]
          ])
        end)

      assert_receive {:worker, worker}, 500
      monitor = Process.monitor(worker)
      Process.exit(caller, :kill)
      assert_receive {:DOWN, ^monitor, :process, ^worker, _}, 500
    end
  end

  test "F-D01/F-D02 fully normalized readiness strictly precedes default/custom deadline" do
    for {timeout, limit} <- [{nil, 5_000_000}, {7, 7000}], delta <- [-1, 0, 1] do
      Process.put(:fixture_elapsed, 0)
      request = if timeout, do: Map.put(@request, :timeout_ms, timeout), else: @request

      assert {:error, error} =
               Providers.catalog(request,
                 positions: %{"FW" => "Forward"},
                 provider: {__MODULE__, {:delay, limit + delta, self()}},
                 runtime: {FixtureRuntime, %{}}
               )

      assert error.category == if(delta < 0, do: :not_found, else: :timeout)
      assert_receive :work
      refute_receive :work
    end

    Process.put(:fixture_elapsed, 0)

    assert {:error, error} =
             Providers.catalog(Map.put(@request, :timeout_ms, 7),
               positions: %{"FW" => "Forward"},
               provider: {__MODULE__, {:delay, 6999, self()}},
               runtime: {FixtureRuntime, %{validation_us: 1}}
             )

    assert error.category == :timeout
  end

  test "F-D05 blocked worker cancellation, no late reply and next request correlation" do
    assert {:error, error} =
             Providers.catalog(Map.put(@request, :timeout_ms, 20),
               positions: %{"FW" => "Forward"},
               provider: {__MODULE__, {:blocked, self()}}
             )

    assert error.category == :timeout
    assert_receive {:worker, pid}
    monitor = Process.monitor(pid)
    assert_receive {:DOWN, ^monitor, :process, ^pid, _}, 500

    assert {:error, error} =
             Providers.catalog(@request,
               positions: %{"FW" => "Forward"},
               provider: {__MODULE__, :crash}
             )

    assert error.category == :unavailable
    refute inspect(error) =~ "FAKE_SENTINEL"
    refute_receive {:provider_ready, _, _, _}
    refute_receive {:provider_timeout, _}
  end

  test "F-D05 caller exit cancels worker without waiting for blocked read" do
    owner = self()

    caller =
      spawn(fn ->
        Providers.catalog(@request,
          positions: %{"FW" => "Forward"},
          provider: {__MODULE__, {:blocked, owner}}
        )
      end)

    assert_receive {:worker, worker}, 500
    monitor = Process.monitor(worker)
    Process.exit(caller, :kill)
    assert_receive {:DOWN, ^monitor, :process, ^worker, _}, 500
  end

  test "F-D01 through F-D05 complete source scripts including shared-budget portions" do
    alias FootballMarket.ProviderContractCase, as: Contract

    for id <- Contract.ids("F-D"),
        adapter <- [
          FootballMarket.Providers.FixtureSourceA,
          FootballMarket.Providers.FixtureSourceB
        ],
        do: Contract.assert_contract!(adapter, id)
  end

  test "worker-failure signal at deadline times out; blocking label is bounded" do
    Process.put(:fixture_elapsed, 0)

    assert {:error, error} =
             Providers.catalog(Map.put(@request, :timeout_ms, 7),
               positions: %{"FW" => "Forward"},
               provider: {__MODULE__, {:delay, 0, self()}},
               runtime: {FixtureRuntime, %{failure_us: 7000}}
             )

    assert error.category == :timeout

    assert {:error, error} =
             Providers.catalog(Map.put(@request, :timeout_ms, 10),
               positions: %{"FW" => "Forward"},
               provider: {FootballMarket.Providers.BlockingLabelAdapter, nil}
             )

    assert error.category == :timeout
  end
end
