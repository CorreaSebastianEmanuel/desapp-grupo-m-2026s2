defmodule FootballMarket.Repo.Migrations.AddPlayerScopedStatisticsChecks do
  use Ecto.Migration

  def change do
    drop unique_index(:statistics_import_scopes, [:identity_namespace, :season_id],
           name: :statistics_import_scope_identity_index
         )

    alter table(:statistics_import_scopes) do
      add :player_id, references(:players, type: :uuid, on_delete: :restrict)
    end

    create unique_index(:statistics_import_scopes, [:identity_namespace, :season_id],
             where: "player_id IS NULL",
             name: :statistics_import_scope_identity_index
           )

    create unique_index(:statistics_import_scopes, [:identity_namespace, :season_id, :player_id],
             where: "player_id IS NOT NULL",
             name: :statistics_import_player_scope_identity_index
           )
  end
end
