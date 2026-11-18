defmodule FootballMarket.Repo.Migrations.AddProviderVolumeReservations do
  use Ecto.Migration

  def change do
    alter table(:provider_rate_limits) do
      add :reservations, {:array, :utc_datetime_usec}, null: false, default: []
    end
  end
end
