defmodule FootballMarketWeb.Workspace.Players do
  @moduledoc false
  import Phoenix.Component, only: [assign: 2]
  import Phoenix.LiveView, only: [push_patch: 2]
  import FootballMarketWeb.Workspace.Session
  alias FootballMarket.{Catalog, Quotes}
  alias FootballMarketWeb.Workspace.Portfolio

  def handle_event("search_players", params, socket) do
    query =
      %{
        "q" => String.trim(Map.get(params, "player_search", "")),
        "league_id" => Map.get(params, "league_id", ""),
        "team_id" => Map.get(params, "team_id", ""),
        "position_id" => Map.get(params, "position_id", ""),
        "page_size" => Map.get(params, "page_size", "25")
      }
      |> Enum.reject(fn {_key, value} -> value in ["", nil] end)
      |> Map.new()

    {:noreply,
     push_patch(socket,
       to: "/players?" <> URI.encode_query(query),
       replace: Map.has_key?(params, "_target")
     )}
  end

  def handle_event("quote_date", %{"date" => date}, socket) do
    params =
      %{"player_id" => socket.assigns.card.player.id, "date" => date}
      |> Map.merge(
        Map.take(URI.decode_query(socket.assigns.catalog_state_query || ""), [
          "q",
          "league_id",
          "team_id",
          "position_id",
          "page_size",
          "cursor"
        ])
      )

    {:noreply, push_patch(socket, to: "/players?" <> URI.encode_query(params))}
  end

  def load_card(socket, nil, _params), do: assign(socket, card: nil, quote: nil, card_error: nil)

  def load_card(socket, id, params) do
    case Catalog.player_card(id) do
      {:ok, card} ->
        quote = current_quote(id)
        {history, history_unavailable} = quote_history(id)
        date_param = params["date"] || ""
        dated_quote = dated_quote(id, date_param)

        socket
        |> assign(
          card: card,
          quote: quote,
          quote_history: history,
          quote_history_unavailable: history_unavailable,
          quote_date: date_param,
          dated_quote: dated_quote,
          card_error: nil
        )
        |> Portfolio.reload_portfolio()
        |> Portfolio.reload_issuer_inventory()

      _ ->
        assign(socket, card: nil, card_error: "No se pudo cargar la ficha del jugador.")
    end
  end

  defp current_quote(id) do
    case Quotes.latest(id) do
      {:ok, quote} -> quote
      _ -> nil
    end
  end

  defp quote_history(id) do
    case Quotes.list_history(id) do
      {:ok, rows} -> {rows, false}
      _ -> {[], true}
    end
  end

  defp dated_quote(_id, ""), do: nil

  defp dated_quote(id, value) do
    case Date.from_iso8601(value) do
      {:ok, date} -> dated_quote_at(id, date)
      _ -> :invalid
    end
  end

  defp dated_quote_at(id, date) do
    case Quotes.at_date(id, date) do
      {:ok, row} -> row
      {:error, :quote_not_found} -> :missing
      _ -> :unavailable
    end
  end

  def load_player_page(socket, params) do
    filter_options =
      case Catalog.filter_options() do
        {:ok, options} -> options
        _ -> socket.assigns.catalog_filter_options
      end

    filters =
      params
      |> Enum.filter(fn {key, value} ->
        key in ["league_id", "team_id", "position_id"] and value != ""
      end)
      |> Map.new(fn {key, value} -> {String.to_existing_atom(key), value} end)
      |> maybe_name_filter(params["q"])

    opts = %{
      page_size: page_size(params["page_size"]),
      cursor: params["cursor"],
      filters: filters
    }

    valid_filters? =
      filters
      |> Map.delete(:search_name)
      |> Enum.all?(fn {_key, value} -> match?({:ok, _}, Ecto.UUID.cast(value)) end)

    result =
      if valid_filters?, do: Catalog.list_player_page(opts), else: {:error, :invalid_filters}

    case result do
      {:ok, page} ->
        {players, scouting_status} =
          maybe_scout_name_miss(params["q"], filters, page.players, params["cursor"])

        assign(socket,
          catalog_filter_options: filter_options,
          catalog_pagination: page.pagination,
          player_results: players,
          search_performed: true,
          scouting_status: scouting_status,
          player_search_unavailable: false
        )

      {:error, _} ->
        assign(socket,
          catalog_filter_options: filter_options,
          player_results: [],
          catalog_pagination: nil,
          search_performed: true,
          scouting_status: nil,
          player_search_unavailable: true
        )
    end
  end

  defp maybe_name_filter(filters, nil), do: filters
  defp maybe_name_filter(filters, ""), do: filters
  defp maybe_name_filter(filters, name), do: Map.put(filters, :search_name, name)

  defp maybe_scout_name_miss(nil, _filters, players, _cursor), do: {players, nil}
  defp maybe_scout_name_miss("", _filters, players, _cursor), do: {players, nil}

  defp maybe_scout_name_miss(_name, _filters, players, _cursor) when players != [],
    do: {players, nil}

  defp maybe_scout_name_miss(name, filters, [], cursor) do
    local_miss? = Catalog.search_local_players(name) == {:ok, []}

    if is_nil(cursor) and local_miss? and Map.keys(filters) == [:search_name] do
      case Catalog.search_players(name) do
        {:ok, players, status} -> {players, status}
        _ -> {[], nil}
      end
    else
      {[], nil}
    end
  end
end
