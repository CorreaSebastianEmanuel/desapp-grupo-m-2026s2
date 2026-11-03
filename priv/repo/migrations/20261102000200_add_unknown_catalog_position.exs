defmodule FootballMarket.Repo.Migrations.AddUnknownCatalogPosition do
  use Ecto.Migration

  def up do
    execute """
    INSERT INTO positions (id, code, name, inserted_at, updated_at)
    VALUES ('4c3a3f5b-2a64-4c47-9b7b-9a8891b6d907', 'UNK', 'Sin posición', now(), now())
    ON CONFLICT DO NOTHING
    """
  end

  def down do
    execute """
    DELETE FROM positions
    WHERE code = 'UNK' AND name = 'Sin posición'
      AND NOT EXISTS (SELECT 1 FROM players WHERE players.position_id = positions.id)
    """
  end
end
