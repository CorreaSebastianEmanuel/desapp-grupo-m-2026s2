defmodule FootballMarket.Statistics.Ingestion.Positions do
  @moduledoc "Frozen, match-count based substitute position evidence."

  def derive(subject, committed_history) when is_map(subject) and is_list(committed_history) do
    eligible =
      committed_history
      |> Enum.filter(fn prior ->
        prior.player_id == subject.player_id and prior.season_id == subject.season_id and
          not is_nil(prior.position_id) and
          DateTime.compare(prior.kickoff_at, subject.kickoff_at) == :lt
      end)
      |> Enum.uniq_by(& &1.match_id)
      |> Enum.sort_by(&{&1.match_id, &1.id})

    basis = Enum.map(eligible, &%{performance_id: &1.id, position_id: &1.position_id})
    frequencies = Enum.frequencies_by(eligible, & &1.position_id)

    case Enum.sort_by(frequencies, fn {position, count} -> {-count, position} end) do
      [] ->
        {:ok,
         %{
           basis: basis,
           frequencies: %{},
           position_id: nil,
           reason: :insufficient_history,
           policy_version: 1
         }}

      [{position, count} | rest] ->
        if tied?(rest, count) do
          {:ok,
           %{
             basis: basis,
             frequencies: frequencies,
             position_id: nil,
             reason: :tie,
             policy_version: 1
           }}
        else
          {:ok,
           %{
             basis: basis,
             frequencies: frequencies,
             position_id: position,
             reason: nil,
             policy_version: 1
           }}
        end
    end
  end

  def derive(_, _), do: {:error, :invalid_input}

  defp tied?(rest, count),
    do: Enum.any?(rest, fn {_other, other_count} -> other_count == count end)
end
