defmodule FootballMarket.Catalog.Ingestion.Records do
  @moduledoc "Catalog record writes inside the publisher-owned acceptance transaction."
  import Ecto.Query
  alias FootballMarket.{Market, Repo}
  alias FootballMarket.Catalog.{League, Season, Team, Player}
  alias FootballMarket.Catalog.Ingestion.Reconciler

  def persist_operations(operations, season) do
    Enum.each(operations, fn {row, attrs, operation} ->
      row
      |> persist_operation(attrs, operation, season)
      |> maybe_initialize_primary(operation)
    end)
  end

  defp maybe_initialize_primary(%Player{id: id}, :insert) do
    case Market.initialize_primary_player_in_transaction(id) do
      %{outcome: _status} -> :ok
      {:ok, _status} -> :ok
      {:error, reason} -> Repo.rollback({:initial_player_issuance_failed, reason})
    end
  end

  defp maybe_initialize_primary(_row, _operation), do: :ok

  def league!(fact) do
    row =
      Repo.one(
        from l in League,
          where: fragment("lower(btrim(?))", l.code) == ^Reconciler.normalize(fact.code)
      )

    {row, state} =
      if row do
        {row, "unchanged"}
      else
        now = DateTime.utc_now()

        {count, _} =
          Repo.insert_all(
            League,
            [
              %{
                id: Ecto.UUID.generate(),
                code: fact.code,
                name: fact.name,
                inserted_at: now,
                updated_at: now
              }
            ],
            on_conflict: :nothing
          )

        {Repo.one(
           from l in League,
             where: fragment("lower(btrim(?))", l.code) == ^Reconciler.normalize(fact.code)
         ), if(count == 1, do: "created", else: "unchanged")}
      end

    if is_nil(row) or Reconciler.normalize(row.name) != Reconciler.normalize(fact.name),
      do: Reconciler.conflict(:canonical_league_conflict)

    {row, state}
  end

  def season!(league, scope) do
    keys = [league_id: league.id, start_year: scope.start_year, end_year: scope.end_year]

    case Repo.get_by(Season, keys) do
      nil ->
        now = DateTime.utc_now()

        {count, _} =
          Repo.insert_all(
            Season,
            [
              Map.merge(Map.new(keys), %{
                id: Ecto.UUID.generate(),
                inserted_at: now,
                updated_at: now
              })
            ],
            on_conflict: :nothing
          )

        {Repo.get_by!(Season, keys), if(count == 1, do: "created", else: "unchanged")}

      row ->
        {row, "unchanged"}
    end
  end

  defp player_changeset(row, attrs, operation, season) do
    if operation == :insert,
      do:
        Player.create_changeset(
          row,
          Map.put(attrs, :catalog_identity, row.catalog_identity),
          season.id
        ),
      else: Player.update_changeset(row, attrs, season.id)
  end

  defp persist_operation(row, attrs, operation, season) do
    if operation != :unchanged do
      cs =
        case row do
          %Team{} ->
            Team.changeset(row, attrs)

          %Player{} ->
            player_changeset(row, attrs, operation, season)
        end

      if operation == :insert, do: Repo.insert!(cs), else: Repo.update!(cs)
    end
  end
end
