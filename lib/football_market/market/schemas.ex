defmodule FootballMarket.Market.Error do
  @moduledoc "Safe market domain error returned across controllers and LiveViews."
  @enforce_keys [:kind, :reason]
  defstruct [:kind, :reason]
  @type t :: %__MODULE__{kind: atom(), reason: atom()}

  def new(kind, reason), do: {:error, %__MODULE__{kind: kind, reason: reason}}
end

defmodule FootballMarket.Market.MoneyChangeset do
  @moduledoc false
  import Ecto.Changeset

  @doc "Validates that money fields are exact non-negative 2-decimal `Decimal` values (never floats)."
  def cast_exact(record, attrs, cast_fields, money_fields) do
    changeset = cast(record, attrs, cast_fields)

    Enum.reduce(money_fields, changeset, fn field, acc ->
      raw = Map.get(attrs, field, Map.get(attrs, Atom.to_string(field)))
      value = get_field(acc, field)

      valid? =
        case value do
          %Decimal{coef: coef, sign: sign} when is_integer(coef) ->
            (sign == 1 or coef == 0) and Decimal.equal?(value, Decimal.round(value, 2))

          nil ->
            true

          _ ->
            false
        end

      if is_float(raw) or not valid?,
        do: add_error(acc, field, "must be exact finite cents"),
        else: acc
    end)
  end
end

defmodule FootballMarket.Market.InitializationLock do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :integer, autogenerate: false}
  schema "market_initialization_locks" do
  end
end

defmodule FootballMarket.Market.InitialRecipient do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :binary_id

  schema "market_initial_recipients" do
    belongs_to :user, FootballMarket.Accounts.User
    field :fixed_at, :utc_datetime_usec
  end
end

defmodule FootballMarket.Market.Holding do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "market_holdings" do
    belongs_to :player, FootballMarket.Catalog.Player
    belongs_to :user, FootballMarket.Accounts.User
    field :quantity, :integer
  end
end

defmodule FootballMarket.Market.Quote do
  @moduledoc false
  use Ecto.Schema

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
end

defmodule FootballMarket.Market.Issuance do
  @moduledoc false
  use Ecto.Schema

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
    FootballMarket.Market.MoneyChangeset.cast_exact(
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
    FootballMarket.Market.MoneyChangeset.cast_exact(
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
