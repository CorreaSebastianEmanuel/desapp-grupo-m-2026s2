defmodule FootballMarket.Quotes.Membership do
  @moduledoc false
  alias FootballMarket.Repo

  def snapshot_import!(intent_id, performance_ids) do
    changed = rows_by_ids(performance_ids)

    changed
    |> Enum.group_by(fn row ->
      start = week_start(row.kickoff_at)
      {row.player_id, row.season_id, start}
    end)
    |> Enum.each(fn {{player_id, season_id, start}, _rows} ->
      finish = DateTime.add(start, 7 * 24 * 60 * 60, :second)
      members = rows_for_scope(player_id, season_id, start, finish)
      ids = Enum.map(members, & &1.id)
      material = Enum.map(members, & &1.fact_material)
      digest = :crypto.hash(:sha256, Jason.encode!(material)) |> Base.encode16(case: :lower)
      snapshot_id = Ecto.UUID.generate()

      Repo.insert_all("quote_import_scope_snapshots", [
        %{
          id: Ecto.UUID.dump!(snapshot_id),
          intent_id: Ecto.UUID.dump!(intent_id),
          player_id: Ecto.UUID.dump!(player_id),
          season_id: Ecto.UUID.dump!(season_id),
          week_start: start,
          week_end: finish,
          schema_version: 1,
          membership: Enum.map(ids, &Ecto.UUID.dump!/1),
          fact_material: material,
          digest: digest,
          inserted_at: DateTime.utc_now() |> DateTime.truncate(:microsecond)
        }
      ])

      Repo.insert_all(
        "quote_import_snapshot_facts",
        Enum.with_index(members, 1)
        |> Enum.map(fn {member, ordinal} ->
          %{
            snapshot_id: Ecto.UUID.dump!(snapshot_id),
            performance_id: Ecto.UUID.dump!(member.id),
            ordinal: ordinal,
            fact_material: member.fact_material,
            inserted_at: DateTime.utc_now() |> DateTime.truncate(:microsecond)
          }
        end)
      )
    end)

    :ok
  end

  def snapshots(intent_id) do
    case Ecto.UUID.cast(intent_id) do
      {:ok, id} ->
        {:ok,
         Repo.query!(
           "SELECT id, player_id, season_id, week_start, week_end, membership, fact_material, digest FROM quote_import_scope_snapshots WHERE intent_id=$1 ORDER BY player_id, week_start",
           [Ecto.UUID.dump!(id)]
         ).rows}

      _ ->
        {:error, :invalid_intent}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def enqueue_import!(intent_id) do
    {:ok, id} = Ecto.UUID.cast(intent_id)
    mapping = Application.get_env(:football_market, :quote_mapping_id)

    mapping =
      case Ecto.UUID.cast(mapping) do
        {:ok, value} -> Ecto.UUID.dump!(value)
        _ -> nil
      end

    {:ok, snapshots} = snapshots(id)

    if snapshots == [] do
      record_legacy_requests!(id)
    else
      Repo.query!(
        """
        INSERT INTO quote_calculation_requests
          (id, snapshot_id, intent_id, player_id, season_id, week_start, week_end, selector, mapping_id, state, inserted_at)
        SELECT gen_random_uuid(), s.id, s.intent_id, s.player_id, s.season_id, s.week_start, s.week_end,
          'active', $2, 'pending', now()
        FROM quote_import_scope_snapshots s WHERE s.intent_id=$1
        ON CONFLICT (snapshot_id) WHERE snapshot_id IS NOT NULL DO NOTHING
        """,
        [Ecto.UUID.dump!(id), mapping]
      )
    end

    import Ecto.Query
    alias FootballMarket.Quotes.CalculationRequest
    alias FootballMarket.Workers.QuoteCalculation
    alias FootballMarket.Observability.JobContext

    correlation = Map.get(JobContext.for_intents([id]), id, id)

    for request <-
          Repo.all(
            from r in CalculationRequest, where: r.intent_id == ^id and r.state == "pending"
          ) do
      %{"request_id" => request.id}
      |> QuoteCalculation.new()
      |> JobContext.annotate(correlation)
      |> Repo.insert!()
    end

    :ok
  end

  # Changed facts prove affected scopes, never the original complete membership.
  # Retain a terminal request per known scope rather than silently using today's
  # accepted facts for an intent that predates membership snapshots.
  defp record_legacy_requests!(intent_id) do
    Repo.query!(
      """
      INSERT INTO quote_calculation_requests
        (id, source, intent_id, player_id, season_id, week_start, week_end,
         selector, state, reason, inserted_at)
      SELECT gen_random_uuid(), 'import', scopes.intent_id, scopes.player_id, scopes.season_id,
        scopes.week_start, scopes.week_start + interval '7 days',
        'active', 'unreproducible', 'original_unavailable', now()
      FROM (
        SELECT DISTINCT i.id AS intent_id, p.player_id, p.season_id,
          date_trunc('week', m.kickoff_at) AS week_start
        FROM statistics_calculation_intents i
        JOIN player_match_performances p ON p.id = ANY(i.changed_performance_ids)
        JOIN matches m ON m.id = p.match_id
        WHERE i.id = $1
      ) scopes
      ON CONFLICT (intent_id, player_id, season_id, week_start)
        WHERE snapshot_id IS NULL AND source = 'import' DO NOTHING
      """,
      [Ecto.UUID.dump!(intent_id)]
    )
  end

  def facts(materials) when is_list(materials) do
    mats =
      Enum.map(materials, fn material ->
        %{
          "performance_id" => material["id"],
          "match_id" => material["match_id"],
          "player_id" => material["player_id"],
          "season_id" => material["season_id"],
          "team_id" => material["team_id"],
          "position_id" => material["position_id"],
          "home_team_id" => material["home_team_id"],
          "away_team_id" => material["away_team_id"],
          "match_identity" => material["match_identity"],
          "kickoff" => persisted_kickoff(material["kickoff_at"]),
          "minutes" => material["minutes_played"],
          "metrics" =>
            Map.new(FootballMarket.Valuation.Request.metrics(), fn metric ->
              {Atom.to_string(metric), material[Atom.to_string(metric)]}
            end)
        }
      end)

    FootballMarket.Quotes.EvidenceCodec.decode_facts(mats)
  end

  def facts(_), do: {:error, :invalid_evidence}

  # Snapshot materials are persisted through Postgres jsonb, which serializes
  # the utc_datetime_usec kickoff without its UTC designator or microsecond
  # precision; restore both so the durable replay equals the live evidence
  # shape (live facts carry six-digit microsecond precision).
  defp persisted_kickoff(value) when is_binary(value) do
    base = String.replace_suffix(value, "Z", "")

    zone =
      case Regex.run(~r/([+-][0-9][0-9]:?[0-9][0-9])$/, base) do
        [captured] -> captured
        _ -> nil
      end

    without_zone = if zone, do: String.replace_suffix(base, zone, ""), else: base

    time =
      if String.contains?(without_zone, "."), do: without_zone, else: without_zone <> ".000000"

    if from_iso8601_shape?(time),
      do: String.replace(time, " ", "T") <> (zone || "Z"),
      else: base
  end

  # Only normalizes the persisted shape ("date time" without zone) when it
  # looks like an ISO ext representation; otherwise the value is returned
  # untouched for the codec to classify.
  defp from_iso8601_shape?(value) do
    Regex.match?(~r/^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}(\.\d+)?$/, value)
  end

  defp rows_by_ids(ids) do
    query = """
    SELECT p.id, p.player_id, p.season_id, m.kickoff_at
    FROM player_match_performances p JOIN matches m ON m.id=p.match_id
    WHERE p.id = ANY($1::uuid[])
    ORDER BY m.kickoff_at, m.match_identity, p.id
    """

    {:ok, %{rows: rows}} = Repo.query(query, [Enum.map(ids, &Ecto.UUID.dump!/1)])

    Enum.map(rows, fn [id, player, season, kickoff] ->
      %{
        id: Ecto.UUID.load!(id),
        player_id: Ecto.UUID.load!(player),
        season_id: Ecto.UUID.load!(season),
        kickoff_at: kickoff
      }
    end)
  end

  defp rows_for_scope(player_id, season_id, from, to) do
    query = """
    SELECT p.id, to_jsonb(p) || jsonb_build_object(
      'match_identity', m.match_identity, 'kickoff_at', m.kickoff_at,
      'home_team_id', m.home_team_id, 'away_team_id', m.away_team_id
    ) AS fact_material
    FROM player_match_performances p JOIN matches m ON m.id=p.match_id
    WHERE p.player_id=$1 AND p.season_id=$2 AND m.kickoff_at >= $3 AND m.kickoff_at < $4
    ORDER BY m.kickoff_at, m.match_identity, p.id
    """

    {:ok, %{rows: rows}} =
      Repo.query(query, [Ecto.UUID.dump!(player_id), Ecto.UUID.dump!(season_id), from, to])

    Enum.map(rows, fn [id, fact] -> %{id: Ecto.UUID.load!(id), fact_material: fact} end)
  end

  defp week_start(kickoff) do
    date =
      case kickoff do
        %DateTime{} -> DateTime.to_date(kickoff)
        %NaiveDateTime{} -> NaiveDateTime.to_date(kickoff)
      end

    monday = Date.add(date, 1 - Date.day_of_week(date))
    DateTime.new!(monday, ~T[00:00:00], "Etc/UTC")
  end
end
