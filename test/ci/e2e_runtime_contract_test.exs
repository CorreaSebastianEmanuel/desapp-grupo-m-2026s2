defmodule FootballMarket.E2E.RuntimeContractTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.E2E.Runtime

  test "fallback cleanup rejects foreign ownership before starting a repository" do
    path = Path.join(System.tmp_dir!(), "e2e-owner-#{System.unique_integer([:positive])}")
    original = Map.new(["PROFILE_RESOURCES", "PROFILE_RESOURCE_NONCE"], &{&1, System.get_env(&1)})
    nonce = String.duplicate("a", 32)
    System.put_env(%{"PROFILE_RESOURCES" => path, "PROFILE_RESOURCE_NONCE" => nonce})

    on_exit(fn ->
      File.rm(path)

      Enum.each(original, fn
        {key, nil} -> System.delete_env(key)
        {key, value} -> System.put_env(key, value)
      end)
    end)

    record = %{
      schema: "e2e_" <> String.duplicate("b", 32),
      nonce: nonce,
      database: FootballMarket.Repo.config()[:database],
      partition: System.get_env("MIX_TEST_PARTITION", "")
    }

    for changed <- [
          %{nonce: "foreign"},
          %{database: "football_market_dev"},
          %{partition: "foreign"}
        ] do
      File.write!(path, Jason.encode!([Map.merge(record, changed)]))
      assert_raise RuntimeError, "invalid resource owner", &Runtime.cleanup_registered!/0
    end

    File.write!(path, Jason.encode!([%{record | schema: "public"}]))
    assert_raise ArgumentError, "unsafe e2e schema", &Runtime.cleanup_registered!/0
  end

  test "database identity is partition-bound and schema identifiers are owned" do
    assert Runtime.validate_database!("football_market_testabc", "abc") == :ok
    assert_raise ArgumentError, fn -> Runtime.validate_database!("football_market_dev", "abc") end

    assert_raise ArgumentError, fn ->
      Runtime.validate_database!("football_market_test", "abc")
    end

    a = Runtime.schema()
    b = Runtime.schema()
    assert a != b
    assert a =~ ~r/^e2e_[a-f0-9]{32}$/
    assert_raise ArgumentError, fn -> Runtime.drop_schema!("public") end
  end

  test "runtime configuration uses real consumers and isolated normal SQL pool" do
    schema = Runtime.schema()
    config = Runtime.configuration(schema, 43210)
    assert config.repo[:pool] == DBConnection.ConnectionPool
    assert config.repo[:parameters] == [search_path: schema]
    assert config.oban[:prefix] == schema
    assert config.oban[:testing] == :disabled
    assert config.oban[:queues] == [catalog_sync: 1]
    assert config.sync[:enabled]
    refute config.sync[:automatic]
    assert config.sync[:sources] == %{}
    assert config.endpoint[:http][:ip] == {127, 0, 0, 1}
    assert config.endpoint[:server]
  end

  test "deadline polling fails rather than accepting unavailable or terminal failed work" do
    assert Runtime.await!(fn -> {:ok, :ready} end, 20) == :ready
    assert_raise RuntimeError, "e2e deadline", fn -> Runtime.await!(fn -> :pending end, 1) end

    assert_raise RuntimeError, "e2e deadline", fn ->
      Runtime.await!(
        fn ->
          Process.sleep(10)
          {:ok, :too_late}
        end,
        1
      )
    end

    assert_raise RuntimeError, "e2e terminal failure", fn ->
      Runtime.await!(fn -> {:error, :failed} end, 20)
    end
  end

  test "scenario failure restores configuration and removes only its migrated owned schema" do
    alias FootballMarket.Repo
    before_config = Application.fetch_env!(:football_market, Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, :manual)
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.mode(Repo, :auto) end)

    schemas = fn ->
      Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
        Ecto.Adapters.SQL.query!(
          Repo,
          "SELECT nspname FROM pg_namespace WHERE nspname LIKE 'e2e_%' ORDER BY nspname",
          []
        ).rows
      end)
    end

    before_schemas = schemas.()

    assert_raise RuntimeError, "controlled lifecycle failure", fn ->
      Runtime.with_runtime!(fn base ->
        assert Repo.config()[:parameters][:search_path] =~ ~r/^e2e_/
        assert Oban.config().testing == :disabled
        assert {200, _, _} = Runtime.get(base <> "/sign-in")
        raise "controlled lifecycle failure"
      end)
    end

    assert Application.fetch_env!(:football_market, Repo) == before_config
    assert schemas.() == before_schemas
  end
end
