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
