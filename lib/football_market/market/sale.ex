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

  def changeset(record, attrs),
    do:
      FootballMarket.Market.Settlement.exact_money_changeset(record, attrs, @cast_fields, [
        :unit_price,
        :total
      ])
end
