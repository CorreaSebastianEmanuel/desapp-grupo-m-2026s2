defmodule FootballMarket.Valuation.Configurations.Registry do
  @moduledoc "Reviewed formula dispatch; persisted data never selects executable modules."
  alias FootballMarket.Valuation.{Balanced, PositionAware, Error}
  def resolve("balanced", "1"), do: {:ok, Balanced}
  def resolve("position_aware", "1"), do: {:ok, PositionAware}
  def resolve(_, _), do: Error.new(:unsupported_strategy, :unknown_identity_version)
end
