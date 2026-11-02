defmodule FootballMarket.Market.CreditBalanceStore do
  @moduledoc false
  import Ecto.Query

  alias FootballMarket.Market.{CreditBalance, Error}
  alias FootballMarket.Repo

  def available(owner_id) do
    amount =
      Repo.one(
        from(balance in CreditBalance,
          where: balance.user_id == ^owner_id,
          select: balance.amount
        )
      )

    {:ok, amount || Decimal.new("0.00")}
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end
end
