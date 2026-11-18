defmodule FootballMarket.Repo.Migrations.ScopeActiveStatisticsImportsByPlayer do
  use Ecto.Migration

  def up do
    drop index(:synchronization_runs, [:operation, :league_code, :start_year, :end_year],
           name: :synchronization_active_scope,
           prefix: prefix()
         )

    create unique_index(
             :synchronization_runs,
             [
               :operation,
               :league_code,
               :start_year,
               :end_year,
               "(CASE WHEN operation = 'statistics' THEN coalesce(input->>'player_id', '') ELSE '' END)"
             ],
             where: "state IN ('queued', 'executing', 'retry_wait')",
             name: :synchronization_active_scope,
             prefix: prefix()
           )
  end

  def down do
    drop index(:synchronization_runs, [:operation, :league_code, :start_year, :end_year],
           name: :synchronization_active_scope,
           prefix: prefix()
         )

    create unique_index(:synchronization_runs, [:operation, :league_code, :start_year, :end_year],
             where: "state IN ('queued', 'executing', 'retry_wait')",
             name: :synchronization_active_scope,
             prefix: prefix()
           )
  end
end
