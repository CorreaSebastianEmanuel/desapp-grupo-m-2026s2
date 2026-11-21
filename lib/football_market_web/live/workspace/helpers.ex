defmodule FootballMarketWeb.Workspace.Helpers do
  @moduledoc """
  Shared formatting, session actor, ranking, and transaction helpers used across
  Workspace LiveView tabs and templates.
  """

  import Phoenix.Component, only: [assign: 2]
  import Phoenix.LiveView, only: [push_patch: 2]

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.{Catalog, Market, Ranking}

  # --- Presentation Formatting ---

  def money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)
  def exact_money(nil), do: "Sin datos"
  def exact_money(value), do: value |> Decimal.normalize() |> Decimal.to_string(:normal)
  def timestamp(value), do: Calendar.strftime(value, "%Y-%m-%d %H:%M:%S UTC")

  def readable_reason(nil), do: "no disponible"
  def readable_reason("insufficient_funds"), do: "saldo insuficiente"
  def readable_reason("insufficient_inventory"), do: "inventario insuficiente"
  def readable_reason(reason), do: String.replace(reason, "_", " ")

  def order_status("pending"), do: "Pendiente"
  def order_status("executed"), do: "Ejecutada"
  def order_status("rejected"), do: "Rechazada"
  def order_status("cancelled"), do: "Cancelada"
  def order_status("expired"), do: "Vencida"
  def order_status(status), do: status

  # --- Session & Actor Helpers ---

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
    case Market.credit_balance(domain_actor(socket.assigns.actor)) do
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

  # --- Ranking & Transaction Tab Loaders ---

  def load_ranking(socket) do
    case Ranking.read() do
      {:ok, ranking} ->
        entries =
          Enum.map(ranking.entries, fn entry ->
            Map.put(entry, :player_name, player_name(entry.player_id))
          end)

        assign(socket, ranking: %{ranking | entries: entries}, ranking_error: nil)

      {:error, :no_active_configuration} ->
        assign(socket, ranking: nil, ranking_error: nil)

      _ ->
        assign(socket,
          ranking: nil,
          ranking_error: "El ranking no está disponible temporalmente."
        )
    end
  end

  def handle_transaction_page_size(%{"page_size" => size}, socket) do
    {:noreply,
     push_patch(socket, to: "/transactions?" <> URI.encode_query(%{"page_size" => size}))}
  end

  def load_transactions(socket, params) do
    size = page_size(params["page_size"])

    case Market.transaction_history(domain_actor(socket.assigns.actor), %{
           page_size: size,
           cursor: params["cursor"]
         }) do
      {:ok, page} ->
        rows =
          Enum.map(page.data, fn row -> Map.put(row, :player_name, player_name(row.player_id)) end)

        assign(socket,
          transactions: rows,
          transaction_pagination: page.pagination,
          transaction_page_size: size,
          transaction_error: false
        )

      {:error, _} ->
        assign(socket,
          transactions: [],
          transaction_pagination: nil,
          transaction_page_size: size,
          transaction_error: true
        )
    end
  end
end

defmodule FootballMarketWeb.Workspace.Pages do
  @moduledoc "HEEx template wrapper rendering the active workspace tab inside the app shell."
  use FootballMarketWeb, :html

  import FootballMarketWeb.WorkspaceComponents
  import FootballMarketWeb.Workspace.Helpers
  alias FootballMarketWeb.PortfolioComponents

  embed_templates "pages/*"

  def render(assigns) do
    ~H"""
    <.shell
      actor={@actor}
      destination={@destination}
      administrator={FootballMarket.Accounts.administrator?(domain_actor(@actor))}
      credit_balance={@credit_balance}
      credit_balance_unavailable={@credit_balance_unavailable}
    >
      <.orders :if={@destination == "/conditional-orders"} {assigns} />
      <.transactions :if={@destination == "/transactions"} {assigns} />
      <.players :if={@destination == "/players"} {assigns} />
      <.ranking :if={@destination == "/ranking"} {assigns} />
      <.portfolio :if={@destination == "/portfolio"} {assigns} />
    </.shell>
    """
  end
end
