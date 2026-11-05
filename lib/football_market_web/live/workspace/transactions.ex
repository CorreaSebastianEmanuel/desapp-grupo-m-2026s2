defmodule FootballMarketWeb.Workspace.Transactions do
  @moduledoc false
  import Phoenix.Component, only: [assign: 2]
  import Phoenix.LiveView, only: [push_patch: 2]
  import FootballMarketWeb.Workspace.Session
  alias FootballMarket.Market

  def handle_event("transaction_page_size", %{"page_size" => size}, socket) do
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
