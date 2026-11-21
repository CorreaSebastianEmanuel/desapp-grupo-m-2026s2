defmodule FootballMarket.Market.Error do
  @moduledoc "Safe market domain failures without storage internals."
  @enforce_keys [:kind, :reason]
  defstruct [:kind, :reason]
  @type t :: %__MODULE__{kind: atom(), reason: atom()}
  def new(kind, reason), do: {:error, %__MODULE__{kind: kind, reason: reason}}
end

defmodule FootballMarket.Market.InitializationLock do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :binary_id
  schema "market_initialization_locks" do
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [])
    |> validate_required([])
  end
end

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

defmodule FootballMarket.Market.Holding do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "market_holdings" do
    belongs_to :player, FootballMarket.Catalog.Player
    belongs_to :user, FootballMarket.Accounts.User
    field :quantity, :integer
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [:player_id, :user_id, :quantity])
    |> validate_required([:player_id, :user_id, :quantity])
    |> foreign_key_constraint(:player_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:player_id, :user_id], name: :market_holding_owner_unique)
    |> check_constraint(:quantity, name: :market_holding_nonnegative)
    |> check_constraint(:quantity, name: :market_supply_conserved)
  end
end

defmodule FootballMarket.Market.Quote do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "market_quotes" do
    belongs_to :player, FootballMarket.Catalog.Player
    field :unit_price, :decimal
    field :effective_at, :utc_datetime_usec
    field :inserted_at, :utc_datetime_usec
    field :rule_id, :string
    field :rule_version, :string
    field :calculation_id, :binary_id
    field :configuration_version_id, :binary_id
    field :mapping_id, :binary_id
    field :performance_sequence, :integer
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [
      :player_id,
      :unit_price,
      :effective_at,
      :inserted_at,
      :rule_id,
      :rule_version,
      :calculation_id,
      :configuration_version_id,
      :mapping_id,
      :performance_sequence
    ])
    |> validate_required([
      :player_id,
      :unit_price,
      :effective_at,
      :inserted_at,
      :rule_id,
      :rule_version
    ])
    |> foreign_key_constraint(:player_id)
    |> unique_constraint(:player_id, name: :market_quote_initial_unique)
    |> check_constraint(:unit_price, name: :market_quote_canonical)
    |> foreign_key_constraint(:calculation_id)
    |> foreign_key_constraint(:configuration_version_id)
    |> foreign_key_constraint(:mapping_id)
  end
end

defmodule FootballMarket.Market.Issuance do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "market_issuances" do
    belongs_to :player, FootballMarket.Catalog.Player
    belongs_to :recipient, FootballMarket.Accounts.User
    belongs_to :initial_quote, FootballMarket.Market.Quote
    field :quantity, :integer
    field :initial_unit_price, :decimal
    field :completed_at, :utc_datetime_usec
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [
      :player_id,
      :recipient_id,
      :initial_quote_id,
      :quantity,
      :initial_unit_price,
      :completed_at
    ])
    |> validate_required([
      :player_id,
      :recipient_id,
      :initial_quote_id,
      :quantity,
      :initial_unit_price,
      :completed_at
    ])
    |> foreign_key_constraint(:player_id)
    |> foreign_key_constraint(:recipient_id)
    |> foreign_key_constraint(:initial_quote_id, name: :market_issuance_quote_player_fkey)
    |> unique_constraint(:player_id, name: :market_issuance_player_unique)
    |> unique_constraint(:initial_quote_id, name: :market_issuance_quote_unique)
    |> check_constraint(:quantity, name: :market_issuance_canonical)
    |> check_constraint(:recipient_id, name: :market_recipient_consistent)
    |> check_constraint(:quantity, name: :market_supply_conserved)
  end
end

defmodule FootballMarket.Market.CreditBalance do
  @moduledoc false
  use Ecto.Schema
  @primary_key false
  schema "market_credit_balances" do
    field :user_id, :binary_id, primary_key: true
    field :amount, :decimal
    field :updated_at, :utc_datetime_usec
  end

  def changeset(record, attrs) do
    FootballMarket.Market.Settlement.exact_money_changeset(
      record,
      attrs,
      [:user_id, :amount, :updated_at],
      [:amount]
    )
  end
end

defmodule FootballMarket.Market.CreditEntry do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "market_credit_entries" do
    field :purchase_id, :binary_id
    field :sale_id, :binary_id
    field :user_id, :binary_id
    field :side, :string
    field :amount, :decimal
    field :inserted_at, :utc_datetime_usec
  end

  def changeset(record, attrs) do
    FootballMarket.Market.Settlement.exact_money_changeset(
      record,
      attrs,
      [:purchase_id, :sale_id, :user_id, :side, :amount, :inserted_at],
      [:amount]
    )
  end
end

defmodule FootballMarket.Market.TokenTransfer do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "market_token_transfers" do
    field :purchase_id, :binary_id
    field :sale_id, :binary_id
    field :player_id, :binary_id
    field :from_user_id, :binary_id
    field :to_user_id, :binary_id
    field :quantity, :integer
    field :inserted_at, :utc_datetime_usec
  end

  def changeset(record, attrs) do
    cast(record, attrs, [
      :purchase_id,
      :sale_id,
      :player_id,
      :from_user_id,
      :to_user_id,
      :quantity,
      :inserted_at
    ])
  end
end

defmodule FootballMarket.Market.Purchase do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "market_purchases" do
    field :conditional_order_id, :binary_id
    field :buyer_id, :binary_id
    field :recipient_id, :binary_id
    field :player_id, :binary_id
    field :quote_id, :binary_id
    field :configuration_version_id, :binary_id
    field :mapping_id, :binary_id
    field :request_key, :string
    field :rule_id, :string
    field :rule_version, :string
    field :quantity, :integer
    field :unit_price, :decimal
    field :total, :decimal
    field :quote_effective_at, :utc_datetime_usec
    field :performance_sequence, :integer
    field :completed_at, :utc_datetime_usec
  end

  @cast_fields [
    :conditional_order_id,
    :buyer_id,
    :recipient_id,
    :player_id,
    :quote_id,
    :configuration_version_id,
    :mapping_id,
    :request_key,
    :rule_id,
    :rule_version,
    :quantity,
    :unit_price,
    :total,
    :quote_effective_at,
    :performance_sequence,
    :completed_at
  ]

  def changeset(record, attrs) do
    FootballMarket.Market.Settlement.exact_money_changeset(record, attrs, @cast_fields, [
      :unit_price,
      :total
    ])
  end
end

defmodule FootballMarket.Market.Sale do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "market_sales" do
    field :seller_id, :binary_id
    field :buyer_id, :binary_id
    field :player_id, :binary_id
    field :quote_id, :binary_id
    field :configuration_version_id, :binary_id
    field :mapping_id, :binary_id
    field :request_key, :string
    field :rule_id, :string
    field :rule_version, :string
    field :quantity, :integer
    field :unit_price, :decimal
    field :total, :decimal
    field :quote_effective_at, :utc_datetime_usec
    field :performance_sequence, :integer
    field :completed_at, :utc_datetime_usec
  end

  @cast_fields [
    :seller_id,
    :buyer_id,
    :player_id,
    :quote_id,
    :configuration_version_id,
    :mapping_id,
    :request_key,
    :rule_id,
    :rule_version,
    :quantity,
    :unit_price,
    :total,
    :quote_effective_at,
    :performance_sequence,
    :completed_at
  ]

  def changeset(record, attrs) do
    FootballMarket.Market.Settlement.exact_money_changeset(record, attrs, @cast_fields, [
      :unit_price,
      :total
    ])
  end
end

defmodule FootballMarket.Market.ConditionalOrder do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "market_conditional_buy_orders" do
    field :owner_id, :binary_id
    field :player_id, :binary_id
    field :quantity, :integer
    field :maximum_unit_price, :decimal
    field :created_at, :utc_datetime_usec
    field :expires_at, :utc_datetime_usec
    field :status, :string, default: "pending"
    field :completed_at, :utc_datetime_usec
    field :rejection_reason, :string
    field :purchase_id, :binary_id
  end
end

defmodule FootballMarket.Market.OrderEvaluationPass do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :integer, autogenerate: false}
  schema "market_order_evaluation_passes" do
    field :state, :string, default: "idle"
    field :generation, :integer, default: 0
    field :cursor_ordinal, :integer, default: 0
    field :rescan_requested, :boolean, default: false
    field :upper_created_at, :utc_datetime_usec
    field :upper_order_id, :binary_id
    field :started_at, :utc_datetime_usec
    field :updated_at, :utc_datetime_usec
  end
end

defmodule FootballMarket.Market.OrderEvaluationMember do
  @moduledoc false
  use Ecto.Schema
  @primary_key false
  schema "market_order_evaluation_members" do
    field :pass_generation, :integer, primary_key: true
    field :ordinal, :integer, primary_key: true
    field :captured_created_at, :utc_datetime_usec
    field :order_id, :binary_id
  end
end
