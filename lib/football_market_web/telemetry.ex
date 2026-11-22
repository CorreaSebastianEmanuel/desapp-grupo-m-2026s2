defmodule FootballMarketWeb.Telemetry do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      FootballMarket.Observability.Metrics,
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp periodic_measurements do
    [{__MODULE__, :measure_vm, []}]
  end

  def measure_vm do
    :telemetry.execute([:vm, :memory], %{total: :erlang.memory(:total)}, %{})
    total = :erlang.statistics(:run_queue_lengths) |> Enum.sum()

    :telemetry.execute(
      [:vm, :total_run_queue_lengths],
      %{total: total},
      %{}
    )
  end
end
