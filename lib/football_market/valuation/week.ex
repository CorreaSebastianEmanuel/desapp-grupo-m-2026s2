defmodule FootballMarket.Valuation.Week do
  @moduledoc false
  alias FootballMarket.Statistics.Input
  alias FootballMarket.Valuation.Error

  def validate(start, finish) do
    with {:ok, a} <- Input.instant(start, :week_start),
         {:ok, b} <- Input.instant(finish, :week_end) do
      if Date.day_of_week(DateTime.to_date(a)) == 1 and a.hour == 0 and a.minute == 0 and
           a.second == 0 and elem(a.microsecond, 0) == 0 and
           DateTime.diff(b, a, :microsecond) == 604_800_000_000,
         do: {:ok, {a, b}},
         else: Error.new(:validation, :invalid_week, [:week_start, :week_end])
    else
      {:error, detail} ->
        Error.new(:validation, :invalid_week, [Map.take(detail, [:field, :reason])])
    end
  end
end
