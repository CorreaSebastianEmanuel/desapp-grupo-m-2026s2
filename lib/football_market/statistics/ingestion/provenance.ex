defmodule FootballMarket.Statistics.Ingestion.Provenance do
  @moduledoc "Closed, source-qualified provenance values for accepted facts."
  alias FootballMarket.Statistics.Ingestion.Identity

  def identity(result, :match, fact) do
    %{
      "kind" => "match",
      "provider" => result.provenance.provider,
      "source_id" => Identity.fetch!(result, :match, fact.ref),
      "league_code" => result.scope.league_code,
      "start_year" => result.scope.start_year,
      "end_year" => result.scope.end_year
    }
  end

  def identity(result, :performance, fact) do
    %{
      "kind" => "performance",
      "provider" => result.provenance.provider,
      "match_source_id" => Identity.fetch!(result, :match, fact.match_ref),
      "player_source_id" => Identity.fetch!(result, :player, fact.player_ref),
      "league_code" => result.scope.league_code,
      "start_year" => result.scope.start_year,
      "end_year" => result.scope.end_year
    }
  end
end
