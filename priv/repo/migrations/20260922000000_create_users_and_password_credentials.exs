defmodule FootballMarket.Repo.Migrations.CreateUsersAndPasswordCredentials do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:email, :text, null: false)
      timestamps(type: :utc_datetime_usec)
    end

    create(constraint(:users, :users_email_not_blank, check: "btrim(email) <> ''"))

    execute(
      "CREATE UNIQUE INDEX users_normalized_email_index ON users (lower(btrim(email)))",
      "DROP INDEX users_normalized_email_index"
    )

    create table(:password_credentials, primary_key: false) do
      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all), primary_key: true)
      add(:password_hash, :text, null: false)
      timestamps(type: :utc_datetime_usec)
    end
  end
end