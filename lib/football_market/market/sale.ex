defmodule FootballMarket.Market.Sale do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "market_sales" do
    field :seller_id, :binary_id
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

  def changeset(record, attrs) do
    changeset =
      cast(record, attrs, [
        :seller_id,
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
      ])

    Enum.reduce([:unit_price, :total], changeset, fn field, acc ->
      raw = Map.get(attrs, field, Map.get(attrs, Atom.to_string(field)))
      value = get_field(acc, field)

      valid =
        case value do
          %Decimal{coef: coefficient, sign: sign} when is_integer(coefficient) ->
            (sign == 1 or coefficient == 0) and Decimal.equal?(value, Decimal.round(value, 2))

          nil ->
            true

          _ ->
            false
        end

      if is_float(raw) or not valid,
        do: add_error(acc, field, "must be exact finite cents"),
        else: acc
    end)
  end
end
