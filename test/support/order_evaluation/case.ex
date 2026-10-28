defmodule FootballMarket.OrderEvaluationCase do
  @moduledoc false
  import ExUnit.Assertions
  require Ecto.Query
  alias FootballMarket.{ConditionalOrdersCase, Repo}
  alias FootballMarket.Market.OrderEvaluation
  alias FootballMarket.Workers.ConditionalOrderEvaluation

  defdelegate fixture(), to: ConditionalOrdersCase
  defdelegate order!(f, terms \\ %{}), to: ConditionalOrdersCase
  defdelegate invariant!(), to: ConditionalOrdersCase

  def isolate_oban(schema) do
    instance = start_oban(schema)
    ExUnit.Callbacks.on_exit(fn -> stop_oban(instance) end)
    :ok
  end

  def start_oban(schema) do
    previous = Application.fetch_env(:football_market, FootballMarket.Synchronization)
    name = {FootballMarket.OrderEvaluation.TestOban, schema}

    previous_repo = Repo.put_dynamic_repo(Repo)

    {:ok, pid} =
      try do
        Oban.start_link(
          name: name,
          repo: Repo,
          prefix: schema,
          queues: [conditional_orders: 1],
          plugins: [],
          # Long owned-schema names exceed PostgreSQL notification channel
          # limits. Job durability is real; test wake notifications stay local.
          notifier: Oban.Notifiers.Isolated,
          testing: :manual,
          get_dynamic_repo: fn -> Repo.get_dynamic_repo() end
        )
      after
        Repo.put_dynamic_repo(previous_repo)
      end

    Process.unlink(pid)
    config = Application.get_env(:football_market, FootballMarket.Synchronization, [])

    Application.put_env(
      :football_market,
      FootballMarket.Synchronization,
      Keyword.put(config, :oban_name, name)
    )

    %{pid: pid, previous: previous}
  end

  def stop_oban(%{pid: pid, previous: previous}) do
    case previous do
      {:ok, value} -> Application.put_env(:football_market, FootballMarket.Synchronization, value)
      :error -> Application.delete_env(:football_market, FootballMarket.Synchronization)
    end

    if Process.alive?(pid), do: Supervisor.stop(pid)
  end

  def perform(args \\ %{"source" => "recovery"}) do
    ConditionalOrderEvaluation.perform(%Oban.Job{args: args, attempt: 1})
  end

  def status(order) do
    Repo.get!(FootballMarket.Market.ConditionalOrder, order.id).status
  end

  def jobs do
    Repo.all(
      Ecto.Query.from(j in Oban.Job,
        where: j.worker == "FootballMarket.Workers.ConditionalOrderEvaluation"
      )
    )
  end

  def fail_jobs! do
    Repo.query!("""
    CREATE FUNCTION reject_evaluation_job() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN RAISE EXCEPTION 'injected job store failure'; END $$
    """)

    Repo.query!(
      "CREATE TRIGGER reject_evaluation_job BEFORE INSERT ON oban_jobs FOR EACH ROW EXECUTE FUNCTION reject_evaluation_job()"
    )
  end

  def repair_jobs! do
    Repo.query!("DROP TRIGGER reject_evaluation_job ON oban_jobs")
  end

  def fail_purchase! do
    Repo.query!("""
    CREATE FUNCTION fail_evaluation_purchase() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN RAISE EXCEPTION 'injected financial failure'; END $$
    """)

    Repo.query!(
      "CREATE TRIGGER fail_evaluation_purchase BEFORE INSERT ON market_credit_entries FOR EACH ROW EXECUTE FUNCTION fail_evaluation_purchase()"
    )
  end

  def repair_purchase!,
    do: Repo.query!("DROP TRIGGER fail_evaluation_purchase ON market_credit_entries")

  def drain do
    assert :ok == OrderEvaluation.run(true)
  end
end
