defmodule FootballMarket.Providers.FootballDataOrg do
  @moduledoc "Football-Data.org v4 current-season catalog source."
  @behaviour FootballMarket.Providers.Adapter
  alias FootballMarket.Providers.{RateLimit, Request}

  @base_url "https://api.football-data.org/v4"
  @min_interval_ms 6_100
  @max_body_bytes 2_000_000
  @positions %{
    "Goalkeeper" => "GK",
    "Defence" => "DEF",
    "Defender" => "DEF",
    "Midfield" => "MID",
    "Midfielder" => "MID",
    "Offence" => "FWD",
    "Forward" => "FWD"
  }

  @impl true
  def provider_label, do: "football-data.org-v4"

  def valid_token?(token) when is_binary(token) and byte_size(token) in 1..512,
    do:
      String.valid?(token) and token == String.trim(token) and
        not Regex.match?(~r/[\p{Cc}\p{Cf}]/u, token)

  def valid_token?(_), do: false

  @impl true
  def read(%{operation: :catalog} = request, context, state) when is_map(state) do
    with token when is_binary(token) <- state[:token],
         true <- valid_token?(token),
         {:ok, competition} <-
           fetch_json(
             "/competitions/#{request.scope.league_code}/teams?season=#{request.scope.start_year}",
             context,
             state
           ),
         {:ok, candidate} <- translate(competition, request, context, state) do
      {:ok, candidate}
    else
      {:error, %{category: _} = error} -> {:error, error}
      _ -> {:error, %{category: :unsupported_capability}}
    end
  end

  def read(_, _, _), do: {:error, %{category: :unsupported_capability}}

  def translate(
        %{
          "count" => count,
          "competition" => %{"code" => code},
          "season" => season,
          "teams" => teams
        },
        request,
        context,
        state
      )
      when is_integer(count) and is_list(teams) and is_map(season) do
    with true <- code == request.scope.league_code,
         true <- count == length(teams) and count > 0,
         {:ok, season_ref, start_year, end_year} <- season(season),
         true <- start_year == request.scope.start_year and end_year == request.scope.end_year,
         {:ok, team_rows, players, bindings} <- teams(teams, request, season_ref, context, state),
         true <- team_rows != [] and players != [],
         {:ok, positions} <- position_rows(context, players) do
      {:ok,
       %{
         operation: :catalog,
         scope: request.scope,
         facts: %{
           league: %{
             ref: "football-data.org:competition:#{code}",
             code: code,
             name: Request.leagues()[code]
           },
           season: %{
             ref: "football-data.org:season:#{season_ref}",
             league_ref: "football-data.org:competition:#{code}",
             start_year: start_year,
             end_year: end_year
           },
           teams: team_rows,
           positions: positions,
           players: players
         },
         bindings: [
           binding(:league, "football-data.org:competition:#{code}", code),
           binding(:season, "football-data.org:season:#{season_ref}", season_ref)
           | bindings
         ]
       }}
    else
      false -> {:error, %{category: :invalid_response}}
      {:error, %{category: _} = error} -> {:error, error}
      _ -> {:error, %{category: :invalid_response}}
    end
  rescue
    _ -> {:error, %{category: :invalid_response}}
  end

  def translate(_, _, _, _), do: {:error, %{category: :invalid_response}}

  defp teams(rows, request, season_ref, context, state) do
    Enum.reduce_while(rows, {:ok, [], [], []}, fn row, {:ok, team_acc, player_acc, binding_acc} ->
      case translate_team(row, request, season_ref, context, state) do
        {:ok, team, players} ->
          team_binding = binding(:team, team.ref, row["id"])
          player_bindings = Enum.map(players, &binding(:player, &1.ref, &1.source_id))
          players = Enum.map(players, &Map.delete(&1, :source_id))

          {:cont,
           {:ok, [team | team_acc], players ++ player_acc,
            [team_binding | player_bindings] ++ binding_acc}}

        error ->
          {:halt, error}
      end
    end)
    |> case do
      {:ok, teams, players, bindings} ->
        {:ok, Enum.reverse(teams), Enum.reverse(players), Enum.reverse(bindings)}

      error ->
        error
    end
  end

  defp translate_team(%{"id" => id, "name" => name}, _request, season_ref, context, state)
       when is_integer(id) and id > 0 and is_binary(name) do
    with {:ok, detail} <- fetch_json("/teams/#{id}", context, state),
         true <- detail["id"] == id and detail["name"] == name,
         code when is_binary(code) and code != "" <- detail["tla"],
         squad when is_list(squad) and squad != [] <- detail["squad"],
         {:ok, players} <- squad(squad, season_ref, id) do
      ref = "football-data.org:team:#{id}"

      {:ok,
       %{ref: ref, season_ref: "football-data.org:season:#{season_ref}", name: name, code: code},
       players}
    else
      {:error, %{category: _} = error} -> {:error, error}
      _ -> {:error, %{category: :invalid_response}}
    end
  end

  defp translate_team(_, _, _, _, _), do: {:error, %{category: :invalid_response}}

  defp squad(rows, season_ref, team_id) do
    Enum.reduce_while(rows, {:ok, []}, fn row, {:ok, acc} ->
      with %{"id" => id, "name" => name, "position" => position}
           when is_integer(id) and id > 0 and is_binary(name) and byte_size(name) > 0 <- row,
           position_code when is_binary(position_code) <- @positions[position] do
        player = %{
          ref: "football-data.org:player:#{id}",
          season_ref: "football-data.org:season:#{season_ref}",
          display_name: String.trim(name),
          team_ref: "football-data.org:team:#{team_id}",
          position_ref: position_code,
          source_id: Integer.to_string(id)
        }

        {:cont, {:ok, [player | acc]}}
      else
        _ -> {:halt, {:error, %{category: :invalid_response}}}
      end
    end)
    |> case do
      {:ok, players} when length(players) == length(rows) -> {:ok, Enum.reverse(players)}
      _ -> {:error, %{category: :invalid_response}}
    end
  end

  defp season(%{"id" => id, "startDate" => start_date, "endDate" => end_date})
       when is_integer(id) do
    with {:ok, start_date} <- Date.from_iso8601(start_date),
         {:ok, end_date} <- Date.from_iso8601(end_date),
         true <- end_date.year in [start_date.year, start_date.year + 1] do
      {:ok, id, start_date.year, end_date.year}
    else
      _ -> {:error, %{category: :invalid_response}}
    end
  end

  defp season(_), do: {:error, %{category: :invalid_response}}

  defp fetch_json(path, context, state) do
    {runtime, runtime_state} = context.runtime
    remaining = context.deadline_us - runtime.now_us(runtime_state)

    if remaining <= 0 do
      {:error, %{category: :timeout}}
    else
      case RateLimit.reserve(state[:token], @min_interval_ms, div(remaining, 1000)) do
        {:ok, wait_ms} ->
          request_after_wait(path, wait_ms, context, state, runtime, runtime_state)

        {:defer, wait_ms} ->
          {:error, %{category: :rate_limited, retry_after_ms: wait_ms}}

        {:error, _} ->
          {:error, %{category: :unavailable}}
      end
    end
  end

  defp request_after_wait(path, wait_ms, context, state, runtime, runtime_state) do
    if wait_ms > 0, do: sleep(wait_ms, context)
    timeout = max(1, div(context.deadline_us - runtime.now_us(runtime_state), 1000))

    case timeout do
      timeout when timeout > 0 -> request(path, state, timeout) |> decode_response(context, state)
      _ -> {:error, %{category: :timeout}}
    end
  end

  defp request(path, state, timeout) do
    case state[:get] do
      fun when is_function(fun, 3) -> fun.(@base_url <> path, state[:token], timeout)
      _ -> http_get(@base_url <> path, state[:token], timeout)
    end
  rescue
    _ -> {:error, %{category: :unavailable}}
  end

  defp http_get(url, token, timeout) do
    _ = Application.ensure_all_started(:inets)
    _ = Application.ensure_all_started(:ssl)

    opts = [
      timeout: timeout,
      connect_timeout: timeout,
      autoredirect: false,
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
      ]
    ]

    case :httpc.request(
           :get,
           {String.to_charlist(url), [{~c"X-Auth-Token", String.to_charlist(token)}]},
           opts,
           body_format: :binary,
           max_body_size: @max_body_bytes
         ) do
      {:ok, {{_, status, _}, headers, body}} -> {:ok, status, headers, body}
      {:error, :timeout} -> {:error, %{category: :timeout}}
      {:error, {:timeout, _}} -> {:error, %{category: :timeout}}
      {:error, _} -> {:error, %{category: :unavailable}}
    end
  end

  defp decode_response({:ok, status, headers, body}, _context, state)
       when status == 200 and is_binary(body) and byte_size(body) <= @max_body_bytes do
    case persist_reset(headers, state) do
      :ok ->
        case Jason.decode(body) do
          {:ok, map} when is_map(map) -> {:ok, map}
          _ -> {:error, %{category: :invalid_response}}
        end

      _ ->
        {:error, %{category: :unavailable}}
    end
  end

  defp decode_response({:ok, 429, headers, _}, _context, state) do
    delay = reset_delay(headers) || @min_interval_ms

    case RateLimit.block(state[:token], delay) do
      :ok -> {:error, %{category: :rate_limited, retry_after_ms: delay}}
      _ -> {:error, %{category: :unavailable, retry_after_ms: delay}}
    end
  end

  defp decode_response({:ok, status, headers, _}, _, _) when status in 500..599,
    do: {:error, retryable_failure(headers)}

  defp decode_response({:ok, status, _, _}, _, _) when status in 400..499,
    do: {:error, %{category: :unsupported_capability}}

  defp decode_response({:error, %{category: _} = error}, _, _), do: {:error, error}
  defp decode_response(_, _, _), do: {:error, %{category: :unavailable}}

  defp persist_reset(headers, state) do
    if header(headers, "x-requests-available-minute") == "0" do
      case reset_delay(headers) do
        delay when is_integer(delay) and delay > 0 -> RateLimit.block(state[:token], delay)
        _ -> :ok
      end
    else
      :ok
    end
  end

  defp reset_delay(headers) do
    case Integer.parse(header(headers, "x-requestcounter-reset") || "") do
      {seconds, _} when seconds > 0 -> seconds * 1000
      _ -> nil
    end
  end

  defp retryable_failure(headers) do
    case Integer.parse(header(headers, "retry-after") || "") do
      {seconds, _} when seconds > 0 -> %{category: :unavailable, retry_after_ms: seconds * 1000}
      _ -> %{category: :unavailable}
    end
  end

  defp header(headers, key) do
    Enum.find_value(headers, fn {name, value} ->
      if String.downcase(to_string(name)) == key, do: to_string(value)
    end)
  end

  defp sleep(milliseconds, %{sleep: fun}) when is_function(fun, 1), do: fun.(milliseconds)
  defp sleep(milliseconds, _), do: Process.sleep(milliseconds)

  defp binding(kind, ref, id), do: %{kind: kind, ref: ref, source_id: to_string(id)}

  defp position_rows(%{positions: configured}, players) when is_map(configured) do
    canonical = %{
      "GK" => "Goalkeeper",
      "DEF" => "Defender",
      "MID" => "Midfielder",
      "FWD" => "Forward"
    }

    rows =
      players
      |> Enum.map(& &1.position_ref)
      |> Enum.uniq()
      |> Enum.map(fn code ->
        name = Map.get(canonical, code)
        if name && configured[code] == name, do: %{ref: code, code: code, name: name}
      end)

    if length(rows) == length(Enum.uniq_by(players, & &1.position_ref)),
      do: {:ok, rows},
      else: {:error, %{category: :invalid_response}}
  end

  defp position_rows(_, _), do: {:error, %{category: :invalid_response}}
end
