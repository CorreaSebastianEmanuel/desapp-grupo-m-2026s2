defmodule FootballMarket.Repo.Migrations.CreateBrowserSessions do
  use Ecto.Migration
  def change do
    create table(:browser_sessions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :handle_digest, :binary, null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      add :status, :text, null: false
      add :started_at, :utc_datetime_usec, null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :ended_at, :utc_datetime_usec
    end
    create unique_index(:browser_sessions, [:handle_digest])
    create index(:browser_sessions, [:user_id])
    create constraint(:browser_sessions, :browser_status, check: "status IN ('anonymous','authenticated','ended')")
    create constraint(:browser_sessions, :browser_identity, check: "status != 'authenticated' OR user_id IS NOT NULL")
    create constraint(:browser_sessions, :browser_deadline, check: "expires_at = started_at + interval '900 seconds'")
    create constraint(:browser_sessions, :browser_digest, check: "octet_length(handle_digest) = 32")
  end
end
