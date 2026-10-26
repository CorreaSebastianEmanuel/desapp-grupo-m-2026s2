defmodule FootballMarket.Repo.Migrations.IndexStatisticsFreshnessReads do
  use Ecto.Migration

  def change do
    create index(
             :synchronization_runs,
             [:operation, :league_code, :start_year, :end_year, :source_ref, :requested_at, :id],
             name: :synchronization_freshness_lookup
           )

    create index(:quote_import_scope_snapshots, [:player_id, :season_id, :intent_id],
             name: :quote_player_import_lookup
           )
  end
end
