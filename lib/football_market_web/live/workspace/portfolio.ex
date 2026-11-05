defmodule FootballMarketWeb.Workspace.Portfolio do
  @moduledoc false
  import Phoenix.Component, only: [assign: 2]
  import Phoenix.LiveView, only: [push_patch: 2]
  import FootballMarketWeb.Workspace.Session
  alias FootballMarket.Market
  alias FootballMarket.Market.{Portfolio, InitialInventory, Analytics.Input}

  def handle_event("portfolio_range", params, socket) do
    query =
      %{"from" => params["from"], "to" => params["to"], "tab" => socket.assigns.portfolio_tab}
      |> Enum.reject(fn {_key, value} -> value in ["", nil] end)
      |> Map.new()

    {:noreply,
     push_patch(socket,
       to:
         if(map_size(query) == 0,
           do: "/portfolio",
           else: "/portfolio?" <> URI.encode_query(query)
         )
     )}
  end

  def reload_portfolio(socket) do
    case Portfolio.list(domain_actor(socket.assigns.actor)) do
      {:ok, positions} -> assign(socket, positions: positions, portfolio_unavailable: false)
      {:error, _} -> assign(socket, positions: [], portfolio_unavailable: true)
    end
  end

  def reload_issuer_inventory(socket) do
    case InitialInventory.list(domain_actor(socket.assigns.actor)) do
      {:ok, inventory} ->
        assign(socket, issuer_inventory: inventory, issuer_inventory_unavailable: false)

      {:error, _} ->
        assign(socket, issuer_inventory: [], issuer_inventory_unavailable: true)
    end
  end

  def reload_charts(%{assigns: %{destination: "/portfolio", actor: actor}} = socket)
      when not is_nil(actor) do
    domain_actor = domain_actor(actor)

    {allocation, allocation_unavailable} =
      chart_read(fn -> Market.portfolio_allocation(domain_actor) end)

    {history, history_unavailable, range_invalid} =
      case portfolio_options(socket.assigns.portfolio_from, socket.assigns.portfolio_to) do
        {:ok, options} ->
          case Market.portfolio_history(domain_actor, options) do
            {:ok, value} ->
              {value, false, false}

            {:error, %{kind: kind}} when kind in [:invalid_date, :invalid_date_range] ->
              {nil, false, true}

            {:error, _} ->
              {nil, true, false}
          end

        {:error, _} ->
          {nil, false, true}
      end

    assign(socket,
      allocation: allocation,
      allocation_unavailable: allocation_unavailable,
      portfolio_history: history,
      history_unavailable: history_unavailable,
      portfolio_range_invalid: range_invalid
    )
  end

  def reload_charts(socket), do: socket

  defp chart_read(read) do
    case read.() do
      {:ok, data} -> {data, false}
      {:error, _} -> {nil, true}
    end
  end

  defp portfolio_options("", ""), do: Input.range(%{}, Date.utc_today())

  defp portfolio_options(from, to) do
    with {:ok, parsed_from} <- optional_date(from),
         {:ok, parsed_to} <- optional_date(to) do
      Input.range(%{from: parsed_from, to: parsed_to}, Date.utc_today())
    end
  end

  defp optional_date(""), do: {:ok, nil}
  defp optional_date(value) when is_binary(value), do: Date.from_iso8601(value)
  defp optional_date(_), do: {:error, :invalid_date}
end
