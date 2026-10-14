defmodule FootballMarket.MarketCase do
  @moduledoc "Owned committed PostgreSQL fixtures; no shared financial cleanup."
  import ExUnit.Assertions
  alias FootballMarket.Repo

  def inventory do
    [
      "config/config.exs",
      "lib/football_market/market.ex",
      "priv/repo/migrations/20261014000000_create_initial_player_issuance.exs",
      "test/support/market_case.ex",
      "test/football_market/statistics/scope_test.exs",
      "test/football_market/providers/scope_test.exs"
    ] ++
      Enum.map(
        ~w(input consistency error store initialization_lock initial_recipient holding quote issuance),
        &"lib/football_market/market/#{&1}.ex"
      ) ++
      Enum.map(
        ~w(input consistency issuance storage durability retry concurrency rollback rejection scope),
        &"test/football_market/market/#{&1}_test.exs"
      )
  end

  def allowed(feature, path),
    do: feature == "specs/062-initial-player-token-issuance" and path in inventory()

  def private_schema do
    assert Repo.config()[:database] ==
             "football_market_test" <> System.get_env("MIX_TEST_PARTITION", "")

    schema = "market_test_" <> String.replace(Ecto.UUID.generate(), "-", "")

    if Repo.get_dynamic_repo() == Repo do
      Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
        Repo.query!("CREATE SCHEMA " <> schema)
      end)
    else
      Repo.query!("CREATE SCHEMA " <> schema)
    end

    {:ok, pid} = client(schema)
    previous = Repo.put_dynamic_repo(pid)
    old_compiler = Code.compiler_options(ignore_module_conflict: true)

    try do
      Ecto.Migrator.run(Repo, "priv/repo/migrations", :up, all: true, prefix: schema, log: false)
    after
      Code.compiler_options(old_compiler)
    end

    old = Application.get_env(:football_market, :initial_issuance_recipients)

    ExUnit.Callbacks.on_exit(fn ->
      Repo.put_dynamic_repo(previous)
      Application.put_env(:football_market, :initial_issuance_recipients, old)
      if Process.alive?(pid), do: Supervisor.stop(pid)
    end)

    %{schema: schema, repo: pid}
  end

  def client(schema) do
    assert Regex.match?(~r/^market_test_[a-f0-9]+$/, schema)

    {:ok, pid} =
      Repo.start_link(
        name: nil,
        pool: DBConnection.ConnectionPool,
        pool_size: 3,
        parameters: [search_path: schema]
      )

    Process.unlink(pid)
    {:ok, pid}
  end

  def in_client(schema, fun) do
    {:ok, pid} = client(schema)
    previous = Repo.put_dynamic_repo(pid)

    try do
      fun.()
    after
      Repo.put_dynamic_repo(previous)
      Supervisor.stop(pid)
    end
  end

  def fixture do
    %{players: [player, other]} = FootballMarket.CatalogCase.insert_catalog!(["Initial", "Other"])

    users =
      for n <- 1..2 do
        {:ok, account} =
          FootballMarket.Accounts.register_user(%{
            email: "market#{n}-#{System.unique_integer([:positive])}@example.test",
            password: "market-fixture-password"
          })

        user = Repo.get!(FootballMarket.Accounts.User, account.id)

        FootballMarket.Accounts.ApiKey.changeset(
          %FootballMarket.Accounts.ApiKey{},
          %{user_id: user.id, secret_hash: :crypto.strong_rand_bytes(32)}
        )
        |> Repo.insert!()

        user
      end

    [owner, buyer] = users

    Repo.query!(
      "CREATE TABLE balance_sentinels(user_id uuid PRIMARY KEY, credits numeric NOT NULL)"
    )

    for {u, value} <- [{owner, "321.25"}, {buyer, "91.03"}] do
      Repo.query!("INSERT INTO balance_sentinels VALUES($1,$2)", [
        Ecto.UUID.dump!(u.id),
        Decimal.new(value)
      ])
    end

    Application.put_env(:football_market, :initial_issuance_recipients, [owner.id])
    %{player: player, other: other, owner: owner, buyer: buyer}
  end

  def snapshot do
    Map.new(
      ~w(market_initial_recipients market_quotes market_holdings market_issuances users password_credentials api_keys balance_sentinels),
      fn table ->
        rows =
          Repo.query!("SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text").rows

        # Compare every field while keeping account credential material out of
        # assertion failures and captured evidence.
        {table, Enum.map(rows, fn [row] -> :crypto.hash(:sha256, row) end)}
      end
    )
  end

  def market_empty? do
    Enum.all?(
      ~w(market_initial_recipients market_quotes market_holdings market_issuances),
      fn t -> Repo.query!("SELECT count(*) FROM #{t}").rows == [[0]] end
    )
  end

  def later_quote(player, value \\ "2") do
    Repo.insert!(
      struct!(FootballMarket.Market.Quote, %{
        player_id: player.id,
        unit_price: Decimal.new(value),
        effective_at: DateTime.utc_now(),
        inserted_at: DateTime.utc_now(),
        rule_id: "fixture",
        rule_version: "1"
      })
    )
  end

  def transfer(f, quantity) do
    Repo.transaction(fn ->
      Repo.query!("SELECT id FROM players WHERE id=$1 FOR UPDATE", [Ecto.UUID.dump!(f.player.id)])

      Repo.query!(
        "UPDATE market_holdings SET quantity=$1 WHERE player_id=$2 AND user_id=$3",
        [100 - quantity, Ecto.UUID.dump!(f.player.id), Ecto.UUID.dump!(f.owner.id)]
      )

      Repo.insert!(
        struct!(FootballMarket.Market.Holding, %{
          player_id: f.player.id,
          user_id: f.buyer.id,
          quantity: quantity
        })
      )
    end)
  end

  def fresh(schema, code) do
    script = """
    import ExUnit.Assertions
    alias FootballMarket.{Repo, Market, MarketCase}
    {:ok, client} = MarketCase.client(#{inspect(schema)})
    Repo.put_dynamic_repo(client)
    #{code}
    IO.puts("MARKET_FRESH_PASS")
    """

    {out, status} =
      System.cmd("mix", ["run", "--no-compile", "-e", script],
        env: [{"MIX_ENV", "test"}],
        stderr_to_stdout: true
      )

    assert status == 0, "fresh BEAM failed: " <> String.slice(out, -2000, 2000)
    assert out =~ "MARKET_FRESH_PASS"
  end

  def barrier(owner, ref, payload) do
    send(owner, {ref, self(), payload})

    receive do
      {^ref, :go} -> :ok
    after
      10_000 -> raise "market barrier timed out"
    end
  end

  def backend, do: Repo.query!("SELECT pg_backend_pid()").rows |> hd() |> hd()

  def blocked(pid, attempts \\ 200)
  def blocked(_, 0), do: flunk("no PostgreSQL blocking evidence")

  def blocked(pid, attempts) do
    case Repo.query!("SELECT cardinality(pg_blocking_pids($1))", [pid]).rows do
      [[n]] when n > 0 ->
        :ok

      _ ->
        Process.sleep(10)
        blocked(pid, attempts - 1)
    end
  end

  def legacy_namespace(schema) do
    legacy = "market_test_" <> String.replace(Ecto.UUID.generate(), "-", "")
    Repo.query!("CREATE SCHEMA #{legacy}")

    for t <-
          ~w(players users market_initialization_locks market_initial_recipients market_quotes market_holdings market_issuances password_credentials api_keys balance_sentinels) do
      Repo.query!("CREATE TABLE #{legacy}.#{t} AS TABLE #{schema}.#{t}")
    end

    legacy
  end

  def assert_error(result, expected) do
    assert {:error, %FootballMarket.Market.Error{kind: kind}} = result
    assert kind == expected
  end
end
