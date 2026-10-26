defmodule FootballMarket.Ranking do
  @moduledoc "Read-only ranking for the currently active valuation configuration."

  alias FootballMarket.Ranking.Reader

  @typedoc "One eligible player's selected active-configuration performance quote."
  @type entry :: %{
          player_id: Ecto.UUID.t(),
          quote_id: Ecto.UUID.t(),
          unit_price: Decimal.t(),
          effective_at: DateTime.t(),
          position: pos_integer()
        }

  @typedoc "The active configuration and deterministic ordered ranking entries."
  @type result :: %{configuration: map(), entries: [entry()]}

  @spec read() ::
          {:ok, result()} | {:error, :no_active_configuration | :storage_unavailable}

  def read, do: Reader.read()
end
