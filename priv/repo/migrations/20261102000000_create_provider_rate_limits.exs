defmodule FootballMarket.Repo.Migrations.CreateProviderRateLimits do
  use Ecto.Migration

  def change do
    create table(:provider_rate_limits, primary_key: false) do
      add :credential_key, :string, primary_key: true
      add :next_allowed_at, :utc_datetime_usec, null: false
      add :blocked_until, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end
  end
end
