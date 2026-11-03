defmodule FootballMarket.Catalog.Profiles do
  @moduledoc "Batched public identities and optional imagery for locally persisted players."
  import Ecto.Query
  alias FootballMarket.{Repo, Providers.Media}
  alias FootballMarket.Catalog.{Player, Ingestion.SourceBinding}

  def get_many([]), do: %{}

  def get_many(ids) do
    players =
      Repo.all(
        from p in Player,
          where: p.id in ^Enum.uniq(ids),
          preload: [:position, team: [season: :league]]
      )

    team_ids = Enum.map(players, & &1.team_id)

    bindings =
      Repo.all(
        from b in SourceBinding,
          where: b.player_id in ^ids or b.team_id in ^team_ids,
          order_by: [asc: b.provider, asc: b.source_id]
      )

    Map.new(players, fn p ->
      {p.id,
       %{
         name: p.display_name,
         team: p.team.name,
         league: p.team.season.league.name,
         position: p.position.code,
         photo: image(bindings, :player_id, p.id, "player"),
         crest: image(bindings, :team_id, p.team_id, "team")
       }}
    end)
  end

  defp image(bindings, field, id, kind) do
    Enum.find_value(bindings, fn binding ->
      if Map.get(binding, field) == id and binding.kind == kind,
        do: Media.url(binding.provider, kind, binding.source_id)
    end)
  end
end
