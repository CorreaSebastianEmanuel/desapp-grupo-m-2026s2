defmodule FootballMarket.Accounts.ApiKey do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Inspect, except: [:secret_hash]}
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "api_keys" do
    belongs_to(:user, FootballMarket.Accounts.User, type: :binary_id)
    field(:secret_hash, :binary)
    field(:revoked_at, :utc_datetime_usec)
    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @doc false
  def changeset(key, attrs) do
    key
    |> cast(attrs, [:user_id, :secret_hash])
    |> validate_required([:user_id, :secret_hash])
    |> foreign_key_constraint(:user_id)
    |> check_constraint(:secret_hash, name: :api_keys_secret_hash_32_bytes)
    |> unique_constraint(:secret_hash, name: :api_keys_secret_hash_index)
  end
end
