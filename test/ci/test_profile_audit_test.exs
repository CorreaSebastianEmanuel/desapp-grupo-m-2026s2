defmodule FootballMarket.TestProfileAuditTest do
  use ExUnit.Case, async: true

  @moduletag :unit

  alias FootballMarket.TestProfileAudit

  test "rejects absent, duplicate, unknown, test-level, skipped, and empty profile memberships" do
    for {name, source, message} <- [
          {"absent", "defmodule FixtureTest do\nuse ExUnit.Case\nend", "one module-level"},
          {"duplicate",
           "defmodule FixtureTest do\n@moduletag :unit\n@moduletag :integration\nend",
           "one module-level"},
          {"unknown", "defmodule FixtureTest do\n@moduletag :smoke\nend", "unknown module tag"},
          {"test_level", "defmodule FixtureTest do\n@moduletag :unit\n@tag :integration\nend",
           "test-level"},
          {"skip", "defmodule FixtureTest do\n@moduletag :unit\n@tag :skip\nend", "skip"}
        ] do
      root = fixture_root(name, source)
      assert_raise ArgumentError, ~r/#{message}/, fn -> TestProfileAudit.audit!("unit", root) end
    end

    root = fixture_root("empty", "defmodule FixtureTest do\n@moduletag :integration\nend")

    assert_raise ArgumentError, ~r/empty unit scope/, fn ->
      TestProfileAudit.audit!("unit", root)
    end
  end

  test "returns deterministic, exclusive module identities" do
    root = Path.join(System.tmp_dir!(), "cp1-audit-#{System.unique_integer([:positive])}")
    write_fixture(root, "b_test.exs", "defmodule BTest do\n@moduletag :unit\nend")
    write_fixture(root, "a_test.exs", "defmodule ATest do\n@moduletag :unit\nend")
    write_fixture(root, "i_test.exs", "defmodule ITest do\n@moduletag :integration\nend")

    assert %{count: 2, ids: ids} = TestProfileAudit.audit!("unit", root)
    assert ids == Enum.sort(ids)
    assert %{count: 1} = TestProfileAudit.audit!("integration", root)
  end

  test "audits every module in a file and selects the file once per profile" do
    root =
      fixture_root(
        "multiple",
        "defmodule ZTest do\n@moduletag :unit\nend\n" <>
          "defmodule ATest do\n@moduletag :unit\nend\n" <>
          "defmodule ITest do\n@moduletag :integration\nend"
      )

    assert %{count: 2, ids: ids, files: ["test/fixtures/fixture_test.exs"]} =
             TestProfileAudit.audit!("unit", root)

    assert ids == Enum.sort(ids)

    assert %{count: 1, files: ["test/fixtures/fixture_test.exs"]} =
             TestProfileAudit.audit!("integration", root)
  end

  test "runs independently committed integration fixtures after transactional integration tests" do
    files = TestProfileAudit.audit!("integration").files

    committed = [
      "test/football_market/catalog/ingestion/concurrency_test.exs",
      "test/football_market/catalog/ingestion/matrix_test.exs",
      "test/football_market/statistics/concurrency_test.exs",
      "test/football_market/statistics/ingestion/concurrency_test.exs",
      "test/football_market/statistics/ingestion/recovery_test.exs",
      "test/football_market/quotes/concurrency_test.exs",
      "test/football_market/quotes/replay_test.exs",
      "test/football_market/quotes/outcomes_test.exs",
      "test/football_market/synchronization/concurrency_test.exs",
      "test/football_market/synchronization/statistics_test.exs",
      "test/mix/tasks/catalog.seed_test.exs",
      "test/football_market/catalog/development_seed_test.exs",
      "test/football_market/catalog/constraints_test.exs"
    ]

    assert Enum.take(files, -length(committed)) == committed
  end

  test "rejects an unclassified second module" do
    root =
      fixture_root(
        "second_without_profile",
        "defmodule FirstTest do\n@moduletag :unit\nend\n" <>
          "defmodule SecondTest do\nuse ExUnit.Case\nend"
      )

    assert_raise ArgumentError, ~r/one module-level CP1 profile tag/, fn ->
      TestProfileAudit.audit!("unit", root)
    end
  end

  test "E2E ownership is explicit and indirect tags remain rejected" do
    root = fixture_root("e2e", "defmodule JourneyTest do\n@moduletag :e2e\nend")
    assert %{count: 1} = TestProfileAudit.audit!("e2e", root)
    root = fixture_root("indirect", "defmodule IndirectTest do\n@moduletag profile()\nend")

    assert_raise ArgumentError, ~r/unknown module tag/, fn ->
      TestProfileAudit.audit!("unit", root)
    end
  end

  test "independent case inventory rejects removal substitution duplicate and cross-profile cases" do
    a = %{file: "test/a_test.exs", case_id: "A:test first", profile: "unit"}
    b = %{a | case_id: "A:test second"}
    assert :ok = TestProfileAudit.assert_membership!([a, b], [b, a])

    for {expected, found} <- [
          {[a], []},
          {[], [a]},
          {[a], [b]},
          {[a, a], [a]},
          {[a], [%{a | profile: "integration"}]}
        ] do
      assert_raise ArgumentError, fn -> TestProfileAudit.assert_membership!(expected, found) end
    end
  end

  defp fixture_root(name, source) do
    root = Path.join(System.tmp_dir!(), "cp1-audit-#{name}-#{System.unique_integer([:positive])}")
    write_fixture(root, "fixture_test.exs", source)
    root
  end

  defp write_fixture(root, name, source) do
    path = Path.join([root, "test", "fixtures", name])
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, source)
  end
end

defmodule FootballMarket.TestProfileFormatterTest do
  use ExUnit.Case, async: false

  @moduletag :unit

  alias FootballMarket.TestProfileFormatter, as: Formatter

  setup do
    path = Path.join(System.tmp_dir!(), "profile-formatter-#{System.unique_integer([:positive])}")
    File.touch!(path)

    original =
      Map.new(["PROFILE_EVENTS", "PROFILE_NONCE", "CP1_PROFILE"], &{&1, System.get_env(&1)})

    nonce = String.duplicate("a", 32)
    System.put_env(%{"PROFILE_EVENTS" => path, "PROFILE_NONCE" => nonce, "CP1_PROFILE" => "unit"})
    {:ok, identity} = Formatter.init([])

    on_exit(fn ->
      Enum.each(original, fn
        {key, nil} -> System.delete_env(key)
        {key, value} -> System.put_env(key, value)
      end)

      File.rm!(path)
    end)

    %{path: path, identity: identity, nonce: nonce}
  end

  test "case events retain invocation identity when the environment changes", context do
    System.put_env("PROFILE_NONCE", String.duplicate("b", 32))
    test = example(nil)
    assert {:noreply, identity} = Formatter.handle_cast({:test_started, test}, context.identity)
    assert identity == context.identity
    Formatter.handle_cast({:test_finished, test}, identity)

    assert [started, passed] = events(context.path)
    assert Enum.map([started, passed], & &1["state"]) == ["started", "passed"]

    for event <- [started, passed] do
      assert event["nonce"] == context.nonce
      assert event["runner"] == "exunit"
      assert event["file"] == "test/ci/test_profile_audit_test.exs"
      assert event["case_id"] == "FootballMarket.TestProfileFormatterTest:test controlled case"
    end
  end

  test "executed cases from another profile remain visible for rejection", context do
    test = %{example(nil) | tags: %{file: __ENV__.file, integration: true}}
    Formatter.handle_cast({:test_started, test}, context.identity)
    Formatter.handle_cast({:test_finished, test}, context.identity)
    assert Enum.map(events(context.path), & &1["state"]) == ["started", "passed"]
  end

  test "failed and skipped cases cannot become successful or expose diagnostics", context do
    failure =
      {:failed,
       [
         {:error, RuntimeError.exception("credential-sentinel"),
          [{__MODULE__, :controlled, 0, [file: ~c"test/controlled_test.exs", line: 77]}]}
       ]}

    Formatter.handle_cast({:test_finished, example(failure)}, context.identity)

    Formatter.handle_cast(
      {:test_finished, example({:skipped, "credential-sentinel"})},
      context.identity
    )

    assert [failed, skipped] = events(context.path)
    assert failed["state"] == "failed"
    assert failed["failure_line"] == 77
    assert skipped["state"] == "skipped"
    refute File.read!(context.path) =~ "credential-sentinel"
  end

  test "excluded cases and unrelated formatter messages do not count as execution", context do
    Formatter.handle_cast(
      {:test_started, example({:excluded, "other profile"})},
      context.identity
    )

    Formatter.handle_cast(
      {:test_finished, example({:excluded, "other profile"})},
      context.identity
    )

    assert {:noreply, identity} = Formatter.handle_cast({:suite_finished, %{}}, context.identity)
    assert identity == context.identity
    assert events(context.path) == []
  end

  defp example(state) do
    %ExUnit.Test{
      module: __MODULE__,
      name: :"test controlled case",
      state: state,
      tags: %{file: __ENV__.file, unit: true}
    }
  end

  defp events(path) do
    path |> File.read!() |> String.split("\n", trim: true) |> Enum.map(&Jason.decode!/1)
  end
end
