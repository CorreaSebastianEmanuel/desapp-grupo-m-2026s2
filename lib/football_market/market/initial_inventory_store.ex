defmodule FootballMarket.Market.InitialInventoryStore do
  @moduledoc false
  import Ecto.Query

  alias FootballMarket.Catalog.Player
  alias FootballMarket.Market.{Error, Holding, InitialRecipient, Issuance}
  alias FootballMarket.Repo

  def list(recipient_id) do
    query =
      from(i in Issuance,
        join: h in Holding,
        on: h.player_id == i.player_id and h.user_id == i.recipient_id,
        join: p in Player,
        on: p.id == i.player_id,
        where: i.recipient_id == ^recipient_id and h.quantity > 0,
        order_by: [asc: p.display_name, asc: p.id],
        select: %{player_id: p.id, player_name: p.display_name, quantity: h.quantity}
      )

    {:ok, Repo.all(query)}
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  def initial_recipient?(recipient_id) do
    {:ok,
     Repo.exists?(from(recipient in InitialRecipient, where: recipient.user_id == ^recipient_id))}
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end
end
