defmodule FootballMarket.Providers.FootballDataOrgTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  alias FootballMarket.Providers.{FootballDataOrg, Request, Runtime, Validator}
  alias FootballMarket.Synchronization.Input

  @scope %{league_code: "PL", start_year: 2026, end_year: 2027}

  test "retrieves a whole current-season team and squad snapshot with stable source bindings" do
    requests = Agent.start_link(fn -> [] end) |> elem(1)

    get = fn url, token, _timeout ->
      assert token == "runtime-only-token"
      Agent.update(requests, &[url | &1])
      response(url)
    end

    sleeps = Agent.start_link(fn -> [] end) |> elem(1)
    sleep = fn ms -> Agent.update(sleeps, &[ms | &1]) end
    state = %{token: "runtime-only-token", get: get, sleep: sleep}
    {:ok, request} = Request.normalize(:catalog, @scope)

    context = %{
      deadline_us: System.monotonic_time(:microsecond) + 30_000_000,
      runtime: {Runtime, nil},
      positions: %{
        "GK" => "Goalkeeper",
        "DEF" => "Defender",
        "MID" => "Midfielder",
        "FWD" => "Forward"
      }
    }

    assert {:ok, candidate} = FootballDataOrg.read(request, context, state)

    assert {:ok, result} =
             Validator.validate(candidate, request, context, FootballDataOrg.provider_label())

    assert result.provenance.provider == "football-data.org-v4"
    assert Enum.map(result.facts.teams, & &1.code) == ["ARS", "AVL"]
    assert Enum.map(result.facts.players, & &1.display_name) == ["Alex Keeper", "Bea Forward"]

    assert Enum.map(result.provenance.bindings, &{&1.kind, &1.source_id}) |> Enum.sort() ==
             [
               {:league, "PL"},
               {:player, "9001"},
               {:player, "9002"},
               {:season, "733"},
               {:team, "65"},
               {:team, "66"}
             ]

    assert Enum.map(Agent.get(requests, & &1), &URI.parse(&1).path) ==
             ["/v4/teams/66", "/v4/teams/65", "/v4/competitions/PL/teams"]

    assert Agent.get(sleeps, & &1) |> Enum.all?(&(&1 >= 6_000))

    assert {:ok, replay} = FootballDataOrg.read(request, context, state)
    assert replay.facts == candidate.facts
    assert replay.bindings == candidate.bindings
  end

  test "rejects missing, empty, or malformed squad data before publication" do
    assert FootballDataOrg.valid_token?("valid-token")
    refute FootballDataOrg.valid_token?("  invalid-token  ")
    refute FootballDataOrg.valid_token?(nil)

    {:ok, request} = Request.normalize(:catalog, @scope)

    context = %{
      deadline_us: System.monotonic_time(:microsecond) + 30_000_000,
      runtime: {Runtime, nil}
    }

    state = %{
      token: "runtime-only-token",
      get: fn url, _, _ -> response(url, "empty") end,
      sleep: fn _ -> :ok end
    }

    assert {:error, %{category: :invalid_response}} =
             FootballDataOrg.read(request, context, state)

    assert {:error, %{category: :unsupported_capability}} =
             FootballDataOrg.read(request, context, %{state | token: nil})

    invalid_position = %{state | get: fn url, _, _ -> response(url, "invalid_position") end}

    assert {:error, %{category: :invalid_response}} =
             FootballDataOrg.read(request, context, invalid_position)
  end

  test "honors a provider rate-limit reset without retrying the HTTP request" do
    {:ok, request} = Request.normalize(:catalog, @scope)
    sleeps = Agent.start_link(fn -> [] end) |> elem(1)

    context = %{
      deadline_us: System.monotonic_time(:microsecond) + 30_000_000,
      runtime: {Runtime, nil},
      sleep: fn ms -> Agent.update(sleeps, &[ms | &1]) end
    }

    calls = Agent.start_link(fn -> 0 end) |> elem(1)

    state = %{
      token: "runtime-only-token",
      get: fn _url, _token, _timeout ->
        Agent.update(calls, &(&1 + 1))
        {:ok, 429, [{"x-requests-available-minute", "0"}, {"x-requestcounter-reset", "3"}], "{}"}
      end,
      sleep: fn _ -> :ok end
    }

    assert {:error, %{category: :rate_limited, retry_after_ms: 3_000}} =
             FootballDataOrg.read(request, context, state)

    assert Agent.get(calls, & &1) == 1
    assert Agent.get(sleeps, & &1) == []
  end

  test "preserves retryable failures from later team resources through translation" do
    {:ok, request} = Request.normalize(:catalog, @scope)

    context = %{
      deadline_us: System.monotonic_time(:microsecond) + 30_000_000,
      runtime: {Runtime, nil},
      sleep: fn _ -> :ok end
    }

    competition = %{
      "count" => 1,
      "competition" => %{"code" => "PL"},
      "season" => %{"id" => 733, "startDate" => "2026-08-01", "endDate" => "2027-05-30"},
      "teams" => [%{"id" => 65, "name" => "Arsenal"}]
    }

    for {response, expected} <- [
          {{:ok, 429, [{"x-requests-available-minute", "0"}, {"x-requestcounter-reset", "120"}],
            "{}"}, %{category: :rate_limited, retry_after_ms: 120_000}},
          {{:ok, 503, [{"retry-after", "90"}], "{}"},
           %{category: :unavailable, retry_after_ms: 90_000}},
          {{:error, %{category: :timeout}}, %{category: :timeout}}
        ] do
      state = %{
        token: "runtime-only-token",
        get: fn _url, _token, _timeout -> response end,
        sleep: fn _ -> :ok end
      }

      assert {:error, ^expected} =
               FootballDataOrg.translate(competition, request, context, state)

      error = FootballMarket.Providers.Error.failure(expected, request)
      assert error.retryable
      assert error.retry_after_ms == expected[:retry_after_ms]
    end
  end

  test "source configuration identity does not include the runtime API credential" do
    secret = "credential-that-must-not-be-persisted"

    source = %{
      provider: {FootballDataOrg, %{token: secret}},
      identity: %{api: "football-data.org", version: "v4"}
    }

    assert {:ok, identity} = Input.source_identity(source)
    refute inspect(identity) =~ secret
  end

  defp response(url, mode \\ "valid") do
    body =
      cond do
        URI.parse(url).path =~ "/competitions/" ->
          %{
            "count" => 2,
            "competition" => %{"code" => "PL"},
            "season" => %{"id" => 733, "startDate" => "2026-08-01", "endDate" => "2027-05-30"},
            "teams" => [
              %{"id" => 65, "name" => "Arsenal FC"},
              %{"id" => 66, "name" => "Aston Villa FC"}
            ]
          }

        mode == "empty" ->
          %{"id" => 65, "name" => "Arsenal FC", "tla" => "ARS", "squad" => []}

        mode == "invalid_position" ->
          %{
            "id" => 65,
            "name" => "Arsenal FC",
            "tla" => "ARS",
            "squad" => [%{"id" => 9001, "name" => "Alex Keeper", "position" => "Coach"}]
          }

        String.ends_with?(URI.parse(url).path, "/66") ->
          %{
            "id" => 66,
            "name" => "Aston Villa FC",
            "tla" => "AVL",
            "squad" => [%{"id" => 9002, "name" => "Bea Forward", "position" => "Offence"}]
          }

        true ->
          %{
            "id" => 65,
            "name" => "Arsenal FC",
            "tla" => "ARS",
            "squad" => [%{"id" => 9001, "name" => "Alex Keeper", "position" => "Goalkeeper"}]
          }
      end

    headers =
      if mode == "reset",
        do: [{"x-requests-available-minute", "0"}, {"x-requestcounter-reset", "3"}],
        else: []

    {:ok, 200, headers, Jason.encode!(body)}
  end
end
