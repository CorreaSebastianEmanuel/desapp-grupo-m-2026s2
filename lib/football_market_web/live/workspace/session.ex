defmodule FootballMarketWeb.Workspace.Session do
  @moduledoc false
  import Phoenix.Component, only: [assign: 2]
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.{Market, Catalog}
  alias FootballMarket.Market.CreditBalances

  def player_name(id) do
    case Catalog.get_player_detail(id) do
      {:ok, player} -> player.display_name
      _ -> "Jugador"
    end
  end

  def page_size(value) when is_binary(value) do
    case Integer.parse(value) do
      {size, ""} when size in 1..100 -> size
      _ -> 25
    end
  end

  def page_size(_), do: 25

  def reload_credit_balance(socket) do
    case CreditBalances.available(domain_actor(socket.assigns.actor)) do
      {:ok, balance} ->
        assign(socket, credit_balance: balance, credit_balance_unavailable: false)

      {:error, _} ->
        assign(socket, credit_balance: nil, credit_balance_unavailable: true)
    end
  end

  def reload_initial_recipient(socket) do
    case Market.initial_recipient?(domain_actor(socket.assigns.actor)) do
      {:ok, recipient?} ->
        assign(socket, initial_recipient: recipient?, initial_recipient_unavailable: false)

      {:error, _} ->
        assign(socket, initial_recipient: false, initial_recipient_unavailable: true)
    end
  end

  def domain_actor(actor) do
    %AuthenticatedActor{
      account_id: actor.account_id,
      authentication_method: :browser,
      credential_id: actor.session_id
    }
  end

  def quantity(value) when is_binary(value) do
    if Regex.match?(~r/\A[0-9]+\z/, value),
      do: {:ok, String.to_integer(value)},
      else: {:error, :invalid_request}
  end

  def quantity(_), do: {:error, :invalid_request}
end
