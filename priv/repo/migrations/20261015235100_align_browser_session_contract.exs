defmodule FootballMarket.Repo.Migrations.AlignBrowserSessionContract do
  use Ecto.Migration
  def change do
    rename table(:browser_sessions), :handle_digest, to: :token_digest
    rename table(:browser_sessions), :status, to: :state
    rename table(:browser_sessions), :ended_at, to: :revoked_at
    drop constraint(:browser_sessions, :browser_status)
    execute "UPDATE browser_sessions SET state = 'revoked' WHERE state = 'ended'", "UPDATE browser_sessions SET state = 'ended' WHERE state = 'revoked'"
    create constraint(:browser_sessions, :browser_state, check: "state IN ('anonymous','authenticated','revoked')")
    create constraint(:browser_sessions, :browser_revocation, check: "(state = 'revoked') = (revoked_at IS NOT NULL)")
    create constraint(:browser_sessions, :browser_anonymous, check: "state != 'anonymous' OR user_id IS NULL")
    drop constraint(:browser_sessions, :browser_sessions_user_id_fkey)
    alter table(:browser_sessions) do
      modify :user_id, references(:users, type: :uuid, on_delete: :restrict)
      timestamps(type: :utc_datetime_usec, default: fragment("now()"))
    end
    create index(:browser_sessions, [:expires_at])
  end
end
