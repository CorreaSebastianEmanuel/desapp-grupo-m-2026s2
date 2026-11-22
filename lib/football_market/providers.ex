defmodule FootballMarket.Providers do
  @moduledoc """
  External football data providers (Football-Data.org API v4 & FotMob public scraper).

  Everything related to external HTTP fetching and parsing lives in this file:
    * `FootballMarket.Providers` — shared HTTP GET helper & CDN media URL builder
    * `FootballMarket.Providers.FootballDataOrg` — Football-Data.org v4 catalog & matches client
    * `FootballMarket.Providers.Scraping` — FotMob public search & player match history parser
  """

  @doc "Builds a safe HTTPS player photo or team crest URL for a known provider."
  def media_url("fotmob-public-html", "player", source_id) when is_binary(source_id) do
    if Regex.match?(~r/\A[0-9]{1,12}\z/, source_id),
      do: "https://images.fotmob.com/image_resources/playerimages/#{source_id}.png"
  end

  def media_url("football-data-org", "team", source_id) when is_binary(source_id) do
    if Regex.match?(~r/\A[0-9]{1,12}\z/, source_id),
      do: "https://crests.football-data.org/#{source_id}.png"
  end

  def media_url(_, _, _), do: nil

  @doc "Executes an HTTPS GET request using Erlang's built-in `:httpc` with clean timeouts."
  def http_get(url, headers \\ [], timeout_ms \\ 15_000) when is_binary(url) do
    :inets.start()
    :ssl.start()

    char_headers =
      Enum.map(headers, fn {k, v} -> {String.to_charlist(k), String.to_charlist(v)} end)

    http_opts = [
      timeout: timeout_ms,
      connect_timeout: min(timeout_ms, 5_000),
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        depth: 3,
        customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
      ]
    ]

    case :httpc.request(:get, {String.to_charlist(url), char_headers}, http_opts,
           body_format: :binary
         ) do
      {:ok, {{_http, status, _reason}, resp_headers, body}} ->
        {:ok, %{status: status, headers: resp_headers, body: body}}

      {:error, :timeout} ->
        {:error, :timeout}

      {:error, reason} ->
        {:error, {:transport_error, reason}}
    end
  end

  @position_rules [
    {"GK", ["gk", "goal", "keeper"]},
    {"DEF", ["def", "back"]},
    {"MID", ["mid"]},
    {"FWD", ["fwd", "forward", "strik", "wing", "offen"]}
  ]

  @doc "Maps free-form provider position text into our 4 standard codes (`GK`, `DEF`, `MID`, `FWD`, or `UNK`)."
  def normalize_position(raw) when is_binary(raw) do
    text = raw |> String.trim() |> String.downcase()

    Enum.find_value(@position_rules, "UNK", fn {code, keywords} ->
      if Enum.any?(keywords, &String.contains?(text, &1)), do: code
    end)
  end

  def normalize_position(_), do: "UNK"
end

defmodule FootballMarket.Providers.FootballDataOrg do
  @moduledoc "Client for the Football-Data.org v4 REST API (teams & squads per league/season)."

  alias FootballMarket.Providers

  @base_url "https://api.football-data.org/v4"

  def provider_label, do: "football-data-org"

  @doc "Fetches teams and players for a competition code (e.g. `PL`) and season start year."
  def fetch_catalog(league_code, start_year, end_year, opts \\ []) do
    token = Keyword.get(opts, :token) || System.get_env("FOOTBALL_DATA_ORG_TOKEN")
    http_get = Keyword.get(opts, :http_get, &Providers.http_get/3)

    if is_binary(token) and String.trim(token) != "" do
      url = "#{@base_url}/competitions/#{league_code}/teams?season=#{start_year}"
      headers = [{"X-Auth-Token", token}, {"Accept", "application/json"}]

      case http_get.(url, headers, Keyword.get(opts, :timeout_ms, 15_000)) do
        {:ok, %{status: 200, body: body}} ->
          parse_catalog_response(body, league_code, start_year, end_year)

        {:ok, %{status: 429}} ->
          {:error, :rate_limited}

        {:ok, %{status: status}} when status in [401, 403] ->
          {:error, :access_refused}

        {:ok, %{status: _}} ->
          {:error, :unavailable}

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :missing_configuration}
    end
  end

  @doc "Parses a Football-Data.org `/competitions/:code/teams` JSON payload into catalog entries."
  def parse_catalog_response(body, league_code, start_year, end_year) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, %{"teams" => teams}} when is_list(teams) ->
        {:ok,
         %{
           league_code: league_code,
           start_year: start_year,
           end_year: end_year,
           teams: Enum.map(teams, &parse_team/1),
           players: Enum.flat_map(teams, &parse_team_squad/1)
         }}

      _ ->
        {:error, :invalid_response}
    end
  end

  defp parse_team(team) do
    code = team["tla"] || "TEAM-#{team["id"]}"
    %{code: String.trim(to_string(code)), name: String.trim(to_string(team["name"]))}
  end

  defp parse_team_squad(team) do
    team_code = String.trim(to_string(team["tla"] || "TEAM-#{team["id"]}"))
    squad = if is_list(team["squad"]), do: team["squad"], else: []

    Enum.map(squad, fn player ->
      %{
        team_code: team_code,
        position_code: Providers.normalize_position(player["position"]),
        catalog_identity: "fdo-#{player["id"]}",
        display_name: String.trim(to_string(player["name"]))
      }
    end)
  end
end

defmodule FootballMarket.Providers.Scraping do
  @moduledoc "Public FotMob search & player profile match-history parser."

  alias FootballMarket.Providers

  @base_url "https://www.fotmob.com"

  def provider_label, do: "fotmob-public-html"

  @doc "Searches FotMob's public player search endpoint for a player name."
  def search_player(name, opts \\ []) when is_binary(name) do
    http_get = Keyword.get(opts, :http_get, &Providers.http_get/3)
    url = "#{@base_url}/api/search/suggest?term=#{URI.encode_www_form(name)}"

    case http_get.(url, [{"Accept", "application/json"}], Keyword.get(opts, :timeout_ms, 10_000)) do
      {:ok, %{status: 200, body: body}} -> parse_search_results(body)
      {:ok, %{status: 429}} -> {:error, :rate_limited}
      {:ok, %{status: _}} -> {:error, :unavailable}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc "Parses FotMob search JSON into a list of `%{source_id, name, team_name}` maps."
  def parse_search_results(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, sections} when is_list(sections) ->
        players =
          sections
          |> Enum.flat_map(&Map.get(&1, "suggestions", []))
          |> Enum.filter(&(Map.get(&1, "type") == "player"))
          |> Enum.map(fn item ->
            %{
              source_id: to_string(item["id"]),
              name: String.trim(to_string(item["name"] || "")),
              team_name: String.trim(to_string(item["teamName"] || ""))
            }
          end)
          |> Enum.reject(&(&1.source_id == "" or &1.name == ""))

        {:ok, players}

      _ ->
        {:error, :invalid_response}
    end
  end

  @doc "Extracts completed match performance maps from a FotMob player profile JSON payload."
  def parse_player_matches(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, %{"recentMatches" => matches}} when is_list(matches) ->
        {:ok, Enum.flat_map(matches, &parse_match_row/1)}

      _ ->
        {:error, :invalid_response}
    end
  end

  defp parse_match_row(match) do
    case parse_kickoff(match["matchDate"] || match["utcTime"]) do
      {:ok, kickoff_at} ->
        [
          %{
            match_identity: "fotmob-#{match["id"]}",
            kickoff_at: kickoff_at,
            minutes_played: non_neg_int(match["minutesPlayed"]),
            goals: non_neg_int(match["goals"]),
            assists: non_neg_int(match["assists"]),
            shots_on_target: non_neg_int(match["shotsOnTarget"]),
            tackles: non_neg_int(match["tackles"]),
            interceptions: non_neg_int(match["interceptions"]),
            saves: non_neg_int(match["saves"]),
            goals_conceded: non_neg_int(match["goalsConceded"]),
            yellow_cards: non_neg_int(match["yellowCards"]),
            red_cards: non_neg_int(match["redCards"])
          }
        ]

      :error ->
        []
    end
  end

  defp parse_kickoff(%{"utcTime" => text}), do: parse_kickoff(text)

  defp parse_kickoff(text) when is_binary(text) do
    case DateTime.from_iso8601(text) do
      {:ok, dt, 0} -> {:ok, DateTime.truncate(dt, :microsecond)}
      _ -> :error
    end
  end

  defp parse_kickoff(_), do: :error

  defp non_neg_int(val) when is_integer(val) and val >= 0, do: val
  defp non_neg_int(_), do: nil
end
