defmodule FootballMarket.Valuation.Fact do
  @moduledoc "Immutable accepted local match/performance snapshot."
  defstruct [
    :performance_id,
    :match_id,
    :player_id,
    :season_id,
    :team_id,
    :position_id,
    :home_team_id,
    :away_team_id,
    :match_identity,
    :kickoff,
    :minutes,
    :metrics,
    :group
  ]
end

defmodule FootballMarket.Valuation.ScopeInputs do
  @moduledoc false
  defstruct [:membership, :row_count, :total_minutes, totals: %{}, features: %{}]
end

defmodule FootballMarket.Valuation.Prepared do
  @moduledoc false
  defstruct [:request, :facts, :scopes, :descriptor]
end

defmodule FootballMarket.Valuation.Definition do
  @moduledoc false
  defstruct [:module, :strategy_id, :version, :config]
end

defmodule FootballMarket.Valuation.FeatureView do
  @type t :: %__MODULE__{features: map()}
  defstruct [:features]
end

defmodule FootballMarket.Valuation.ScoreResult do
  @moduledoc false
  defstruct [:score, :prepared, :descriptor]
end

defmodule FootballMarket.Valuation.Descriptor do
  @moduledoc false
  defstruct [
    :request,
    :facts,
    :scopes,
    :strategy,
    :score,
    schema_version: 1,
    normalization: "weekly-count-reference-cap-v1",
    rounding: "six-half-away-v1"
  ]
end
