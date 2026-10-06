defmodule FootballMarket.Providers.FixtureRuntime do
  @moduledoc "Mechanical virtual-time runtime; Runner retains deadline decisions."
  def now_us(_), do: Process.get(:fixture_elapsed, 0)
  def advance(us), do: Process.put(:fixture_elapsed, now_us(nil) + us)

  def utc_now(state) do
    advance(Map.get(state, :validation_us, 0))
    ~U[2026-10-06 12:00:00.000000Z]
  end

  def launch(fun, _deadline, _state) do
    outcome = fun.()
    {outcome, now_us(nil)}
  end

  def await({outcome, ready}, _deadline, state) do
    case Map.get(state, :failure_us) do
      nil ->
        {:ready, outcome, ready}

      elapsed ->
        advance(elapsed)
        :failed
    end
  end

  def cancel(_, _), do: :ok
  def close(_, _), do: :ok
end

defmodule FootballMarket.Providers.BlockingLabelAdapter do
  def provider_label do
    receive do
      :never -> "blocked"
    end
  end

  def read(_, _, _), do: {:error, %{category: :not_found}}
end
