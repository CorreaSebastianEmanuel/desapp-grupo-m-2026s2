defmodule FootballMarket.Providers.Media do
  @moduledoc "Public image locations for identities accepted by the catalog adapters."

  def url("fotmob-public-html-v1", "player", id),
    do: numeric_url(id, "https://images.fotmob.com/image_resources/playerimages/")

  def url("fotmob-public-html-v1", "team", id),
    do: numeric_url(id, "https://images.fotmob.com/image_resources/logo/teamlogo/")

  def url("football-data.org-v4", "team", id),
    do: numeric_url(id, "https://crests.football-data.org/")

  def url(_, _, _), do: nil

  defp numeric_url(id, base) when is_binary(id) do
    if Regex.match?(~r/\A[1-9][0-9]{0,11}\z/, id), do: base <> id <> ".png"
  end

  defp numeric_url(_, _), do: nil
end
