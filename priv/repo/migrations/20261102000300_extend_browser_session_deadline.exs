defmodule FootballMarket.Repo.Migrations.ExtendBrowserSessionDeadline do
  use Ecto.Migration

  def up do
    drop constraint(:browser_sessions, :browser_deadline)

    create constraint(:browser_sessions, :browser_deadline,
             check:
               "expires_at = started_at + interval '900 seconds' OR expires_at = started_at + interval '28800 seconds'"
           )
  end

  def down do
    execute(
      "UPDATE browser_sessions SET expires_at = started_at + interval '900 seconds' WHERE expires_at = started_at + interval '28800 seconds'",
      "UPDATE browser_sessions SET expires_at = started_at + interval '28800 seconds' WHERE expires_at = started_at + interval '900 seconds'"
    )

    drop constraint(:browser_sessions, :browser_deadline)

    create constraint(:browser_sessions, :browser_deadline,
             check: "expires_at = started_at + interval '900 seconds'"
           )
  end
end
