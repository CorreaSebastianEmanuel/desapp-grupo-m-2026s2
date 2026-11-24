defmodule FootballMarket.ProvidersSyncTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  alias FootballMarket.Catalog.PlayerCursor
  alias FootballMarket.Providers
  alias FootballMarket.Providers.{FootballDataOrg, Scraping}
  alias FootballMarket.Quotes
  alias FootballMarket.Workers.ProviderRetry

  test "normalizes provider positions into GK, DEF, MID, FWD, or UNK" do
    assert Providers.normalize_position("Goalkeeper") == "GK"
    assert Providers.normalize_position("Centre-Back") == "DEF"
    assert Providers.normalize_position("Central Midfield") == "MID"
    assert Providers.normalize_position("Right Winger") == "FWD"
    assert Providers.normalize_position("Striker") == "FWD"
    assert Providers.normalize_position("Coach") == "UNK"
    assert Providers.normalize_position(nil) == "UNK"
  end

  test "builds safe CDN media URLs only for numeric IDs on known providers" do
    assert Providers.media_url("fotmob-public-html", "player", "12345") ==
             "https://images.fotmob.com/image_resources/playerimages/12345.png"

    assert Providers.media_url("football-data-org", "team", "57") ==
             "https://crests.football-data.org/57.png"

    assert Providers.media_url("fotmob-public-html", "player", "../etc/passwd") == nil
    assert Providers.media_url("unknown", "player", "123") == nil
  end

  test "parses Football-Data.org competition teams and squads JSON" do
    body =
      Jason.encode!(%{
        "teams" => [
          %{
            "id" => 57,
            "tla" => "ARS",
            "name" => "Arsenal FC",
            "squad" => [
              %{"id" => 101, "name" => "Bukayo Saka", "position" => "Right Winger"},
              %{"id" => 102, "name" => "David Raya", "position" => "Goalkeeper"}
            ]
          }
        ]
      })

    assert {:ok, snapshot} = FootballDataOrg.parse_catalog_response(body, "PL", 2026, 2027)
    assert snapshot.league_code == "PL"
    assert snapshot.teams == [%{code: "ARS", name: "Arsenal FC"}]
    assert length(snapshot.players) == 2
    assert Enum.find(snapshot.players, &(&1.display_name == "Bukayo Saka")).position_code == "FWD"
    assert Enum.find(snapshot.players, &(&1.display_name == "David Raya")).position_code == "GK"
  end

  test "handles Football-Data.org HTTP errors cleanly" do
    assert {:error, :rate_limited} =
             FootballDataOrg.fetch_catalog("PL", 2026, 2027,
               token: "tok",
               http_get: fn _, _, _ -> {:ok, %{status: 429, headers: [], body: ""}} end
             )

    assert {:error, :access_refused} =
             FootballDataOrg.fetch_catalog("PL", 2026, 2027,
               token: "tok",
               http_get: fn _, _, _ -> {:ok, %{status: 403, headers: [], body: ""}} end
             )

    for status <- [400, 404] do
      assert {:error, :invalid_request} =
               FootballDataOrg.fetch_catalog("PL", 2026, 2027,
                 token: "tok",
                 http_get: fn _, _, _ -> {:ok, %{status: status, headers: [], body: ""}} end
               )

      assert ProviderRetry.result(:invalid_request) == {:discard, :provider_failure}
    end

    assert {:error, :unavailable} =
             FootballDataOrg.fetch_catalog("PL", 2026, 2027,
               token: "tok",
               http_get: fn _, _, _ -> {:ok, %{status: 503, headers: [], body: ""}} end
             )

    assert ProviderRetry.result(:unavailable) == {:error, :provider_temporarily_unavailable}

    assert {:error, :missing_configuration} =
             FootballDataOrg.fetch_catalog("PL", 2026, 2027, token: "")
  end

  test "provider requests emit bounded outcome telemetry without payloads or credentials" do
    handler = {__MODULE__, make_ref()}
    parent = self()

    :ok =
      :telemetry.attach(
        handler,
        [:football_market, :provider, :request],
        fn event, measurements, metadata, _ ->
          send(parent, {:provider_event, event, measurements, metadata})
        end,
        nil
      )

    on_exit(fn -> :telemetry.detach(handler) end)

    assert {:error, :access_refused} =
             FootballDataOrg.fetch_catalog("PL", 2026, 2027,
               token: "sensitive-token",
               http_get: fn _, _, _ -> {:ok, %{status: 403}} end
             )

    assert_receive {:provider_event, [:football_market, :provider, :request],
                    %{duration: duration},
                    %{provider: :football_data_org, operation: :catalog, outcome: :access_refused}}

    assert is_integer(duration) and duration >= 0
    refute_received {:provider_event, _, _, %{token: _}}
  end

  test "catalog sync failure policy retries only transient provider outcomes" do
    assert ProviderRetry.result(:rate_limited) == {:error, :provider_temporarily_unavailable}
    assert ProviderRetry.result(:timeout) == {:error, :provider_temporarily_unavailable}

    assert ProviderRetry.result({:transport_error, :econnreset}) ==
             {:error, :provider_temporarily_unavailable}

    for permanent <- [
          :access_refused,
          :missing_configuration,
          :invalid_response,
          :invalid_request
        ] do
      assert ProviderRetry.result(permanent) == {:discard, :provider_failure}
    end
  end

  test "parses FotMob player search and recent match history JSON" do
    search_json =
      Jason.encode!([
        %{
          "suggestions" => [
            %{
              "type" => "player",
              "id" => 999,
              "name" => "Julian Alvarez",
              "teamName" => "Atletico"
            },
            %{"type" => "team", "id" => 1, "name" => "Atletico"}
          ]
        }
      ])

    assert {:ok, [%{source_id: "999", name: "Julian Alvarez", team_name: "Atletico"}]} =
             Scraping.parse_search_results(search_json)

    matches_json =
      Jason.encode!(%{
        "recentMatches" => [
          %{
            "id" => 5001,
            "matchDate" => %{"utcTime" => "2026-10-01T19:00:00Z"},
            "minutesPlayed" => 90,
            "goals" => 2,
            "assists" => 1,
            "yellowCards" => 0,
            "redCards" => 0
          }
        ]
      })

    assert {:ok, [match]} = Scraping.parse_player_matches(matches_json)
    assert match.match_identity == "fotmob-5001"
    assert match.goals == 2
    assert match.minutes_played == 90
  end

  test "malformed provider response shapes fail atomically without raising or dropping rows" do
    assert {:error, :invalid_response} =
             FootballDataOrg.parse_catalog_response(
               ~s({"teams":[{"tla":"ARS","name":"Arsenal","squad":[{"id":null,"name":"Player"}]}]}),
               "PL",
               2026,
               2027
             )

    assert {:error, :invalid_response} =
             Scraping.parse_search_results(
               ~s([{"suggestions":[{"type":"player","id":{},"name":"Player"}]}])
             )

    assert {:error, :invalid_response} =
             Scraping.parse_search_results(
               ~s([{"suggestions":[{"type":"player","name":"Player"}]}])
             )

    assert {:error, :invalid_response} =
             Scraping.parse_player_matches(
               ~s({"recentMatches":[{"id":5001,"matchDate":{"utcTime":"2026-10-01T19:00:00Z"}},{"id":5002,"matchDate":"invalid"}]})
             )
  end

  test "converts scores to exact 2-decimal prices with half-away-from-zero rounding" do
    assert {:ok, price} = Quotes.convert(Decimal.new("1.235"), Decimal.new("10.00"))
    assert Decimal.equal?(price, Decimal.new("12.35"))

    assert {:ok, rounded_up} = Quotes.convert(Decimal.new("0.125"), Decimal.new("1.00"))
    assert Decimal.equal?(rounded_up, Decimal.new("0.13"))

    assert {:no_quote, :nonpositive_score} = Quotes.convert(Decimal.new("0"), Decimal.new("10"))
    assert {:no_quote, :nonpositive_score} = Quotes.convert(Decimal.new("-2"), Decimal.new("10"))
    assert {:error, :invalid_scale} = Quotes.convert(Decimal.new("2"), Decimal.new("0"))
  end

  test "encodes and decodes opaque player pagination cursors bound to filters" do
    id = Ecto.UUID.generate()
    league_id = Ecto.UUID.generate()
    filters = %{league_id: league_id}

    token = PlayerCursor.encode(%{name: "saka", id: id}, filters)
    assert {:ok, %{name: "saka", id: ^id}} = PlayerCursor.decode(token, filters)
    assert {:error, :invalid_cursor} = PlayerCursor.decode(token, %{})
    assert {:error, :invalid_cursor} = PlayerCursor.decode("tampered", filters)
  end
end
