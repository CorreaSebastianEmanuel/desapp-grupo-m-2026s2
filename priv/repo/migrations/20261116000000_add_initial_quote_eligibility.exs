defmodule FootballMarket.Repo.Migrations.AddInitialQuoteEligibility do
  use Ecto.Migration

  def change do
    alter table(:quote_calculation_requests) do
      add :initial_only, :boolean, null: false, default: false
    end
  end
end
