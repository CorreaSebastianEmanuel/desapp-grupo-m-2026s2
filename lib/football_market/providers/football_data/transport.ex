defmodule FootballMarket.Providers.FootballData.Transport do
  @moduledoc "Private fixed-route port; no consumer-selected URLs."
  @callback request(tuple(), String.t(), map(), term()) :: {:ok, map()} | {:error, atom()}
  def path({:discovery, code}) when code in ["PL", "BL1", "PD", "SA", "FL1"],
    do: "/v4/competitions/#{code}"

  def path({:teams, code, year})
      when code in ["PL", "BL1", "PD", "SA", "FL1"] and is_integer(year),
      do: "/v4/competitions/#{code}/teams?season=#{year}"

  def path({:team, id}) when is_integer(id) and id > 0, do: "/v4/teams/#{id}"
  def path({:person, id}) when is_integer(id) and id > 0, do: "/v4/persons/#{id}"
end
