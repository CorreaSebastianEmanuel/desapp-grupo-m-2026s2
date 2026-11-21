defmodule FootballMarket.Statistics.Ingestion.Provenance do
  @moduledoc "Closed, source-qualified provenance identities for accepted match & performance facts."

  alias FootballMarket.Statistics.Ingestion.Canonical

  def identity(result, :match, fact) do
    %{
      "kind" => "match",
      "provider" => result.provenance.provider,
      "source_id" => Canonical.fetch_source_id!(result, :match, fact.ref),
      "league_code" => result.scope.league_code,
      "start_year" => result.scope.start_year,
      "end_year" => result.scope.end_year
    }
  end

  def identity(result, :performance, fact) do
    %{
      "kind" => "performance",
      "provider" => result.provenance.provider,
      "match_source_id" => Canonical.fetch_source_id!(result, :match, fact.match_ref),
      "player_source_id" => Canonical.fetch_source_id!(result, :player, fact.player_ref),
      "league_code" => result.scope.league_code,
      "start_year" => result.scope.start_year,
      "end_year" => result.scope.end_year
    }
  end
end
