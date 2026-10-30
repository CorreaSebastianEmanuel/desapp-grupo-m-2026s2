defmodule FootballMarket.Quotes.Closing do
  @moduledoc "Admits durable quote requests at each league/season market close."
  import Ecto.Query

  alias FootballMarket.{Repo, Catalog.League, Catalog.Season}
  alias FootballMarket.Quotes.{CalculationRequest, Membership, Recovery, Store}
  alias FootballMarket.Synchronization.Scheduler

  @earliest_schedule ~U[2000-01-01 00:00:00Z]

  def admit_due(now \\ nil) do
    now = now || Store.database_clock_now!()

    with {:ok, configured} <- configuration(),
         {:ok, scopes} <- scopes() do
      result =
        Enum.reduce_while(scopes, {:ok, %{imports: 0, ttl: 0}}, fn scope, {:ok, totals} ->
          case close_scope(scope, configured, now) do
            {:ok, counts} ->
              {:cont,
               {:ok,
                %{
                  imports: totals.imports + counts.imports,
                  ttl: totals.ttl + counts.ttl
                }}}

            {:error, reason} ->
              {:halt, {:error, reason}}
          end
        end)

      with {:ok, counts} <- result,
           {:ok, recovered} <- Recovery.recover_pending() do
        {:ok, Map.put(counts, :enqueued, recovered)}
      end
    end
  rescue
    _ -> {:error, :quote_close_unavailable}
  end

  defp configuration do
    config = Application.get_env(:football_market, __MODULE__, [])
    default = Keyword.get(config, :default_recurrence, "0 0 * * *")
    recurrences = Keyword.get(config, :recurrences, %{})

    if is_binary(default) and is_map(recurrences) and
         Enum.all?(Map.values(recurrences), &is_binary/1) do
      {:ok, %{default: default, recurrences: recurrences}}
    else
      {:error, :invalid_quote_close_configuration}
    end
  end

  defp scopes do
    {:ok,
     Repo.all(
       from s in Season,
         join: l in League,
         on: l.id == s.league_id,
         order_by: [asc: l.code, asc: s.start_year, asc: s.end_year],
         select: %{id: s.id, league_code: l.code, start_year: s.start_year, end_year: s.end_year}
     )}
  rescue
    _ -> {:error, :quote_close_unavailable}
  end

  defp close_scope(scope, configured, now) do
    recurrence = Map.get(configured.recurrences, schedule_key(scope), configured.default)

    with {:ok, _expression} <- Scheduler.validate(recurrence),
         due when not is_nil(due) <- Scheduler.latest_due(recurrence, @earliest_schedule, now) do
      Repo.transaction(fn ->
        import_count = admit_import_requests!(scope.id, due)
        ttl_count = admit_ttl_requests!(scope, due)
        %{imports: import_count, ttl: ttl_count}
      end)
      |> case do
        {:ok, counts} -> {:ok, counts}
        {:error, reason} -> {:error, reason}
      end
    else
      nil -> {:ok, %{imports: 0, ttl: 0}}
      _ -> {:error, :invalid_quote_close_recurrence}
    end
  end

  defp schedule_key(scope),
    do: "#{scope.league_code}:#{scope.start_year}-#{scope.end_year}"

  defp admit_import_requests!(season_id, due) do
    {count, _} =
      Repo.update_all(
        from(r in CalculationRequest,
          where:
            r.source == "import" and r.season_id == ^season_id and r.state == "pending" and
              is_nil(r.admitted_at) and r.inserted_at <= ^due
        ),
        set: [admitted_at: due]
      )

    count
  end

  defp admit_ttl_requests!(scope, due) do
    config = Application.get_env(:football_market, FootballMarket.Statistics.Freshness, [])
    ttl_seconds = Keyword.get(config, :ttl_seconds, 86_400)
    mapping_id = Application.get_env(:football_market, :quote_mapping_id)

    with true <- is_integer(ttl_seconds) and ttl_seconds > 0,
         {:ok, mapping_id} <- Ecto.UUID.cast(mapping_id) do
      quote_before = DateTime.add(due, -ttl_seconds, :second)

      ttl_candidates(scope.id, DateTime.to_naive(quote_before), due)
      |> Enum.reduce(0, fn candidate, count ->
        case create_ttl_request(candidate, due, mapping_id) do
          :inserted -> count + 1
          :exists -> count
        end
      end)
    else
      false -> Repo.rollback(:invalid_quote_ttl)
      _ -> 0
    end
  end

  defp ttl_candidates(season_id, quote_before, due) do
    Repo.query!(
      """
      WITH latest_snapshots AS (
        SELECT DISTINCT ON (s.player_id, s.season_id)
          s.player_id, s.season_id, s.week_start, s.week_end, s.membership,
          s.fact_material, s.inserted_at
        FROM quote_import_scope_snapshots s
        WHERE s.season_id = $1 AND s.inserted_at <= $3
        ORDER BY s.player_id, s.season_id, s.inserted_at DESC, s.week_start DESC
      ), latest_quotes AS (
        SELECT DISTINCT ON (c.player_id, c.season_id)
          c.player_id, c.season_id, q.effective_at
        FROM quote_calculations c
        JOIN market_quotes q ON q.calculation_id = c.id
        WHERE c.season_id = $1 AND c.status = 'successful'
        ORDER BY c.player_id, c.season_id, q.effective_at DESC, c.inserted_at DESC
      )
      SELECT s.player_id, s.season_id, s.week_start, s.week_end,
        s.membership, s.fact_material, q.effective_at
      FROM latest_snapshots s
      JOIN latest_quotes q USING (player_id, season_id)
      WHERE q.effective_at <= $2
        AND NOT EXISTS (
          SELECT 1 FROM quote_calculation_requests r
          WHERE r.player_id = s.player_id AND r.season_id = s.season_id
            AND r.state IN ('pending', 'running', 'retrying')
        )
      ORDER BY s.player_id
      """,
      [Ecto.UUID.dump!(season_id), quote_before, due]
    ).rows
  end

  defp create_ttl_request(
         [player_id, season_id, week_start, week_end, membership, material, quote_at],
         due,
         mapping_id
       ) do
    with {:ok, facts} <- Membership.facts(material) do
      key =
        Enum.join(
          [
            Ecto.UUID.load!(player_id),
            Ecto.UUID.load!(season_id),
            NaiveDateTime.to_iso8601(quote_at),
            DateTime.to_iso8601(due)
          ],
          ":"
        )

      fact_material = %{"facts" => FootballMarket.Quotes.EvidenceCodec.encode_facts(facts)}

      result =
        Repo.query!(
          """
          INSERT INTO quote_calculation_requests
            (id, source, player_id, season_id, week_start, week_end, selector, mapping_id,
             explicit_membership, explicit_fact_material, state, attempt_count, lease_fence,
             admitted_at, admission_key, inserted_at)
          VALUES
            (gen_random_uuid(), 'ttl', $1, $2, $3, $4, 'active', $5,
             $6, $7::jsonb, 'pending', 0, 0, $8, $9, $8)
          ON CONFLICT (admission_key) WHERE admission_key IS NOT NULL DO NOTHING
          RETURNING id
          """,
          [
            player_id,
            season_id,
            week_start,
            week_end,
            Ecto.UUID.dump!(mapping_id),
            membership,
            fact_material,
            due,
            key
          ]
        )

      if result.num_rows == 1, do: :inserted, else: :exists
    else
      _ -> Repo.rollback(:ttl_facts_unavailable)
    end
  end
end
