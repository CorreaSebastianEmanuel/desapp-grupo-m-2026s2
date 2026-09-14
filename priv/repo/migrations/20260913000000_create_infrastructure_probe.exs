defmodule FootballMarket.Repo.Migrations.CreateInfrastructureProbe do
  use Ecto.Migration

  def up do
    create table(:infrastructure_probe, primary_key: false) do
      add :key, :string, primary_key: true
      add :marker, :string, null: false
      timestamps(type: :utc_datetime)
    end

    execute "INSERT INTO infrastructure_probe (key, marker, inserted_at, updated_at) VALUES ('migration', 'ready', NOW(), NOW())"
  end

  def down, do: drop(table(:infrastructure_probe))
end
