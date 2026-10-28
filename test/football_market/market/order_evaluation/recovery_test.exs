defmodule FootballMarket.Market.OrderEvaluation.RecoveryTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.OrderEvaluationCase
  alias FootballMarket.ConditionalOrdersCase
  alias FootballMarket.Repo
  alias FootballMarket.Market.OrderEvaluation

  setup do: OrderEvaluationCase.fixture()

  test "lost job and >100 members survive continuation loss and fresh BEAM restart", f do
    orders =
      for index <- 1..102 do
        order = OrderEvaluationCase.order!(f, %{maximum_unit_price: "0.01"})
        if rem(index, 2) == 0, do: ConditionalOrdersCase.due!(order)
        order
      end

    base = DateTime.add(DateTime.utc_now(), -7200)

    Repo.query!(
      "ALTER TABLE market_conditional_buy_orders DISABLE TRIGGER market_order_immutable"
    )

    for {order, index} <- Enum.with_index(orders) do
      Repo.query!("UPDATE market_conditional_buy_orders SET created_at=$1 WHERE id=$2", [
        DateTime.to_naive(DateTime.add(base, index, :microsecond)),
        Ecto.UUID.dump!(order.id)
      ])
    end

    Repo.query!("ALTER TABLE market_conditional_buy_orders ENABLE TRIGGER market_order_immutable")
    assert :ok = OrderEvaluationCase.perform()

    assert Repo.query!(
             "SELECT count(*) FROM market_conditional_buy_orders WHERE status='expired'"
           ).rows == [[50]]

    assert length(OrderEvaluationCase.jobs()) == 103
    Repo.query!("DELETE FROM oban_jobs")

    FootballMarket.MarketCase.fresh(f.schema, """
    :ok = Application.stop(:football_market)
    config = Application.fetch_env!(:football_market, Repo)
    Application.put_env(:football_market, Repo, Keyword.merge(config,
      pool: DBConnection.ConnectionPool, parameters: [search_path: #{inspect(f.schema)}]))
    config = Application.fetch_env!(:football_market, Oban)
    Application.put_env(:football_market, Oban, Keyword.put(config, :prefix, #{inspect(f.schema)}))
    Application.put_env(:football_market, FootballMarket.Market.OrderEvaluation, startup: true)
    {:ok, _} = Application.ensure_all_started(:football_market)
    Repo.put_dynamic_repo(Repo)
    [[args]] = Repo.query!("SELECT args FROM oban_jobs WHERE worker='FootballMarket.Workers.ConditionalOrderRecovery'").rows
    assert :ok = FootballMarket.Workers.ConditionalOrderRecovery.perform(%Oban.Job{args: args})
    assert :ok = FootballMarket.Workers.ConditionalOrderEvaluation.perform(%Oban.Job{args: %{"source" => "continuation"}})
    assert Repo.query!("SELECT count(*) FROM market_conditional_buy_orders WHERE status='expired'").rows == [[51]]
    """)

    assert Repo.query!("SELECT count(*) FROM market_order_evaluation_members").rows == [[0]]
    OrderEvaluationCase.invariant!()
  end

  test "minute cron and startup recovery use existing queue seam", f do
    config = Application.fetch_env!(:football_market, Oban)
    assert config[:queues][:conditional_orders] == 1

    {Oban.Plugins.Cron, options} =
      Enum.find(config[:plugins], fn {module, _} -> module == Oban.Plugins.Cron end)

    assert {"* * * * *", FootballMarket.Workers.ConditionalOrderRecovery} in options[:crontab]
    due = OrderEvaluationCase.order!(f)
    ConditionalOrdersCase.due!(due)
    assert {:ok, _} = OrderEvaluation.startup()
    assert :ok = FootballMarket.Workers.ConditionalOrderRecovery.perform(%Oban.Job{args: %{}})
    assert :ok = OrderEvaluationCase.perform()
    assert OrderEvaluationCase.status(due) == "expired"
  end
end
