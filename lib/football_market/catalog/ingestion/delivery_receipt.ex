defmodule FootballMarket.Catalog.Ingestion.DeliveryReceipt do
  @moduledoc "Neutral fenced publication receipt, confirmed inside the domain transaction."
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_delivery_receipts" do
    field :operation, :string, default: "catalog"
    field :fence, :binary_id
    field :run_id, :binary_id
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :state, :string
    field :outcome, :map
    field :confirmed_at, :utc_datetime_usec
  end

  defdelegate lock!(context, scope), to: FootballMarket.Synchronization.DeliveryReceipt
  defdelegate lock!(context, scope, operation), to: FootballMarket.Synchronization.DeliveryReceipt
  defdelegate confirm!(receipt, outcome), to: FootballMarket.Synchronization.DeliveryReceipt
end
