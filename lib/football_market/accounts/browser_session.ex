defmodule FootballMarket.Accounts.BrowserSession do
  use Ecto.Schema
  @derive {Inspect, except: [:token_digest]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "browser_sessions" do
    field :token_digest, :binary, redact: true
    field :user_id, :binary_id
    field :state, :string
    field :started_at, :utc_datetime_usec
    field :expires_at, :utc_datetime_usec
    field :revoked_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end
end
