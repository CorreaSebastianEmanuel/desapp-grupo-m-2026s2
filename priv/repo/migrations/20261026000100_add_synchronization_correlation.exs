defmodule FootballMarket.Repo.Migrations.AddSynchronizationCorrelation do
  use Ecto.Migration

  def change do
    alter table(:synchronization_runs) do
      add :correlation_id, :string, size: 200
    end
  end
end
