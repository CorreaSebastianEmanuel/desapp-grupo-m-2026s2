defmodule FootballMarket.Repo do
  use Ecto.Repo,
    otp_app: :football_market,
    adapter: Ecto.Adapters.Postgres
end
