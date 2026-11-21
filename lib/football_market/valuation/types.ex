defmodule FootballMarket.Valuation.Error do
  @moduledoc "Ordinary safe no-score outcomes."
  defstruct [:kind, :reason, :message, details: []]

  def new(kind, reason, details \\ []) do
    message =
      case kind do
        :no_recorded_performances -> "sin actuaciones registradas"
        :insufficient_data -> "datos insuficientes"
        _ -> nil
      end

    {:error, %__MODULE__{kind: kind, reason: reason, message: message, details: details}}
  end
end

defmodule FootballMarket.Valuation.Scorer do
  @moduledoc "Trusted reviewed module contract. Only rounded features enter score/2."
  @callback identity() :: {String.t(), String.t()}
  @callback validate_config(map()) :: {:ok, map()} | {:error, term()}
  @callback requirements(map()) :: {:ok, map()} | {:error, term()}
  @callback score(FootballMarket.Valuation.FeatureView.t(), map()) ::
              {:ok, Decimal.t()} | {:error, term()}
end

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

defmodule FootballMarket.Valuation.ManagedDescriptor do
  @moduledoc "One strategy-independent binding of a saved UUID and existing reproduction evidence."
  defstruct [:configuration_version_id, :evidence, schema_version: 1]
end

defmodule FootballMarket.Valuation.ManagedResult do
  @moduledoc false
  defstruct [
    :configuration_version_id,
    :strategy_id,
    :formula_version,
    :score,
    :prepared,
    :descriptor
  ]
end
