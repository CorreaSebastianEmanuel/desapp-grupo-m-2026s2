defmodule FootballMarket.Market.Error do
  @moduledoc "Safe initialization failures without storage internals."
  @enforce_keys [:kind, :reason]
  defstruct [:kind, :reason]
  @type t :: %__MODULE__{kind: atom(), reason: atom()}
  def new(kind, reason), do: {:error, %__MODULE__{kind: kind, reason: reason}}
end
