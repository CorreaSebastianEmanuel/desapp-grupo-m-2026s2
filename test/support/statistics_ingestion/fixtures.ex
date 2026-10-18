defmodule FootballMarket.StatisticsIngestion.Fixtures do
  @moduledoc false
  alias FootballMarket.Providers.Request

  def scope(year \\ 2025), do: %{league_code: "PL", start_year: year, end_year: year + 1}

  def request(scope \\ scope()) do
    {:ok, request} = Request.normalize(:performances, scope)
    request
  end

  def transport_counter, do: Process.get(:statistics_ingestion_transport_calls, 0)
  def reset_transport_counter, do: Process.put(:statistics_ingestion_transport_calls, 0)
end
