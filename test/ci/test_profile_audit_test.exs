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
