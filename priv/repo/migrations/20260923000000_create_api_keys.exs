defmodule FootballMarket.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
      add(:secret_hash, :binary, null: false)
      add(:inserted_at, :utc_datetime_usec, null: false)
      add(:revoked_at, :utc_datetime_usec)
    end

    create(
      constraint(:api_keys, :api_keys_secret_hash_32_bytes,
        check: "octet_length(secret_hash) = 32"
      )
    )

    create(unique_index(:api_keys, [:secret_hash], name: :api_keys_secret_hash_index))
    create(index(:api_keys, [:user_id]))
  end
end
