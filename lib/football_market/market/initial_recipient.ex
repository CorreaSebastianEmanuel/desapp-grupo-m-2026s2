defmodule FootballMarket.Market.InitialRecipient do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :binary_id
  schema "market_initial_recipients" do
    belongs_to :user, FootballMarket.Accounts.User
    field :fixed_at, :utc_datetime_usec
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [:user_id, :fixed_at])
    |> validate_required([:user_id, :fixed_at])
    |> foreign_key_constraint(:user_id)
    |> check_constraint(:id, name: :market_recipient_consistent)
  end
end
