defmodule FootballMarket.Providers.Scraping.Admission do
  @moduledoc "Owns the shared in-memory lease table used by live scraping requests."
  use GenServer

  @table :football_market_scraping_admission

  def start_link(_opts \\ []), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def table, do: GenServer.call(__MODULE__, :table)

  @impl true
  def init(:ok) do
    {:ok, :ets.new(@table, [:named_table, :public, :set, write_concurrency: true])}
  end

  @impl true
  def handle_call(:table, _from, table), do: {:reply, table, table}
end
