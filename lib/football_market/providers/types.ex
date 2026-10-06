defmodule FootballMarket.Providers.Result do
  @moduledoc "Provider-neutral in-memory result value."
  defstruct [:operation, :scope, :facts, :provenance]
end

defmodule FootballMarket.Providers.League do
  @moduledoc "Provider-neutral in-memory league value."
  defstruct [:ref, :code, :name]
end

defmodule FootballMarket.Providers.Season do
  @moduledoc "Provider-neutral in-memory season value."
  defstruct [:ref, :league_ref, :start_year, :end_year]
end

defmodule FootballMarket.Providers.Team do
  @moduledoc "Provider-neutral in-memory team value."
  defstruct [:ref, :season_ref, :name, :code]
end

defmodule FootballMarket.Providers.Position do
  @moduledoc "Provider-neutral in-memory position value."
  defstruct [:ref, :code, :name]
end

defmodule FootballMarket.Providers.Player do
  @moduledoc "Provider-neutral in-memory player value."
  defstruct [:ref, :season_ref, :display_name, :team_ref, :position_ref]
end

defmodule FootballMarket.Providers.Match do
  @moduledoc "Provider-neutral in-memory match value."
  defstruct [:ref, :season_ref, :status, :kickoff_at, :home_team_ref, :away_team_ref]
end

defmodule FootballMarket.Providers.Performance do
  @moduledoc "Provider-neutral in-memory performance value."
  defstruct [:ref, :match_ref, :player_ref, :team_ref, :position_ref, :minutes_played, :counts]
end

defmodule FootballMarket.Providers.Binding do
  @moduledoc "Provider-neutral in-memory binding value."
  defstruct [:provider, :kind, :league_code, :start_year, :end_year, :ref, :source_id]
end
