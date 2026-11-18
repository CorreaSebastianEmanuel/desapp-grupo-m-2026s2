defmodule FootballMarket.Providers.TeamIdentity do
  @moduledoc "Controlled club-name equivalence shared by discovery and scoped source binding."

  @club_tokens ~w(fc cf cfc afc sc sv fsv tsg vfb 1 04 05 07 1899)
  @aliases %{
    "SA" => %{
      "acf fiorentina" => "fiorentina",
      "ssc napoli" => "napoli",
      "us lecce" => "lecce",
      "ss lazio" => "lazio",
      "cagliari calcio" => "cagliari",
      "atalanta bc" => "atalanta",
      "frosinone calcio" => "frosinone",
      "parma calcio 1913" => "parma",
      "bologna 1909" => "bologna",
      "ac milan" => "milan",
      "ac monza" => "monza",
      "as roma" => "roma",
      "como 1907" => "como",
      "internazionale milano" => "inter",
      "us sassuolo calcio" => "sassuolo",
      "udinese calcio" => "udinese"
    },
    "PD" => %{
      "club atletico de madrid" => "atletico madrid",
      "rcd espanyol de barcelona" => "espanyol",
      "rayo vallecano de madrid" => "rayo vallecano",
      "real betis balompie" => "real betis",
      "real racing club de santander" => "racing santander",
      "real sociedad de futbol" => "real sociedad",
      "rc celta de vigo" => "celta vigo",
      "ca osasuna" => "osasuna",
      "levante ud" => "levante",
      "rc deportivo la coruna" => "deportivo a coruna"
    },
    "FL1" => %{
      "le havre ac" => "le havre",
      "olympique lyonnais" => "lyon",
      "rc strasbourg alsace" => "strasbourg",
      "stade brestois 29" => "brest",
      "as monaco" => "monaco",
      "lille osc" => "lille",
      "stade rennais 1901" => "rennes",
      "racing club de lens" => "lens",
      "aj auxerre" => "auxerre",
      "ogc nice" => "nice",
      "angers sco" => "angers",
      "olympique de marseille" => "marseille",
      "es troyes ac" => "troyes"
    }
  }

  def normalize(name, league) when is_binary(name) do
    key =
      name
      |> String.downcase()
      |> :unicode.characters_to_nfd_binary()
      |> String.replace(~r/\p{Mn}/u, "")
      |> String.replace(~r/[^a-z0-9]+/u, " ")
      |> String.split()
      |> Enum.reject(&(&1 in @club_tokens))
      |> Enum.join(" ")

    @aliases |> Map.get(league, %{}) |> Map.get(key, key)
  end

  def normalize(_, _), do: ""
end
