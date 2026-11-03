# Football-Data.org catalog synchronization

Set `FOOTBALL_DATA_ORG_TOKEN` in the application's runtime environment. The
value is read at startup and is never included in synchronization job arguments
or run inspection. With a non-empty token, the application enables the five
daily current-season schedules. They run through the durable catalog sync queue;
each league is validated and published independently.

The season scope is resolved from the UTC date at startup. Restart the
application at the July season boundary so the daily schedules use the new
season's year.

To admit all five leagues once, start IEx with the application and run:

```sh
iex -S mix
```

```elixir
today = Date.utc_today()
start_year = if today.month >= 7, do: today.year, else: today.year - 1

for code <- ["PL", "BL1", "PD", "SA", "FL1"] do
  scope = %{league_code: code, start_year: start_year, end_year: start_year + 1, timeout_ms: 1_800_000}
  options = [
    source_ref: "football-data-org",
    trigger: :initial,
    policy: %{attempt_limit: 3, waits: [60, 300], worker_timeout_ms: 1_830_000}
  ]
  {code, FootballMarket.Synchronization.request_catalog(scope, options)}
end
```

Use `trigger: :manual` for a later operator request; run the call once with the
desired league code to limit it to one league. The API returns durable run IDs;
inspect them through `FootballMarket.Synchronization.get_run/1` or
`FootballMarket.Synchronization.list_runs/2`.

The adapter uses the Football-Data.org v4 API over HTTPS. It spaces requests by
at least 6.1 seconds for the documented 10 requests/minute free-tier ceiling
and honors a longer provider reset interval. A catalog snapshot is published
only after all team and squad resources pass validation.

Existing player matches are resolved by the catalog reconciler. When it reports
an identity conflict, provide explicit `mappings` or `new_players` instructions
on the operator request and inspect the resulting durable outcome; the adapter
does not match players by name alone.

The catalog ingestion contract retains entities omitted from a later snapshot.
This sync does not deactivate or delete players/teams because existing catalog
history may still reference them.
