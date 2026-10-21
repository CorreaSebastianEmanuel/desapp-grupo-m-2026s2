defmodule FootballMarket.CredoInventoryTest do
  use ExUnit.Case, async: false

  @moduletag :unit
  @root Path.expand("../..", __DIR__)
  @script Path.join(@root, "scripts/credo_inventory.exs")
  @credo_config File.read!(Path.join(@root, ".credo.exs"))

  setup do
    directory =
      Path.join(System.tmp_dir!(), "credo-inventory-#{System.unique_integer([:positive])}")

    File.mkdir_p!(Path.join(directory, "lib"))
    File.mkdir_p!(Path.join(directory, "config"))
    File.mkdir_p!(Path.join(directory, "priv"))
    File.mkdir_p!(Path.join(directory, "scripts"))
    File.mkdir_p!(Path.join(directory, "test"))
    File.write!(Path.join(directory, ".credo.exs"), @credo_config)
    File.write!(Path.join(directory, ".formatter.exs"), "[]\n")
    File.write!(Path.join(directory, "mix.lock"), "{}\n")

    File.write!(
      Path.join(directory, "lib/a.ex"),
      "defmodule FixtureA do\n  @moduledoc false\nend\n"
    )

    write_inventory(directory, ["lib/a.ex"], [])
    git!(directory, ["init", "-q"])
    git!(directory, ["add", "."])
    on_exit(fn -> File.rm_rf!(directory) end)
    {:ok, root: directory}
  end

  test "tracked maintained roots and root dotfiles reconcile with Credo's valid source inputs", %{
    root: root
  } do
    File.write!(Path.join(root, ".formatter.exs"), "[]\n")

    for path <- ["config/a.ex", "priv/a.exs", "scripts/a.exs", "test/a_test.exs"] do
      File.write!(Path.join(root, path), "defmodule FixtureRoot do\n  @moduledoc false\nend\n")
    end

    maintained = [
      ".credo.exs",
      ".formatter.exs",
      "config/a.ex",
      "lib/a.ex",
      "priv/a.exs",
      "scripts/a.exs",
      "test/a_test.exs"
    ]

    write_inventory(root, maintained -- [".credo.exs", ".formatter.exs"], [])
    git!(root, ["add", "."])

    assert {output, 0} = run_inventory(root)
    evidence = decode_output(output)
    assert evidence["complete"]
    assert evidence["maintained"] == maintained
    assert evidence["effective"] == evidence["maintained"]
  end

  test "write mode discovers added files and preserves exact reviewed exclusions", %{root: root} do
    File.mkdir_p!(Path.join(root, "specs/old/qa-evidence"))
    File.write!(Path.join(root, "lib/b.ex"), "defmodule FixtureB do\n  @moduledoc false\nend\n")
    File.write!(Path.join(root, "specs/old/qa-evidence/probe.exs"), "IO.puts(:probe)\n")
    exclusion = exclusion("specs/old/qa-evidence/probe.exs")
    write_inventory(root, ["lib/a.ex"], [exclusion])
    git!(root, ["add", "."])

    assert {_output, 0} = run_inventory(root, ["--write-inventory"])
    inventory = Jason.decode!(File.read!(Path.join(root, "config/credo_inventory.json")))
    assert inventory["maintained"] == [".credo.exs", ".formatter.exs", "lib/a.ex", "lib/b.ex"]
    assert inventory["excluded"] == [exclusion]
    assert {_output, 0} = run_inventory(root)
  end

  test "unknown tracked files outside maintained scope fail closed", %{root: root} do
    File.mkdir_p!(Path.join(root, "specs/new"))
    File.write!(Path.join(root, "specs/new/probe.exs"), "IO.puts(:probe)\n")
    git!(root, ["add", "."])

    assert {output, 1} = run_inventory(root, ["--write-inventory"])
    assert decode_output(output)["errors"] == ["unclassified-tracked-source:specs/new/probe.exs"]
  end

  test "invalid exclusion category, duplicate entries, and maintained-root suppression fail", %{
    root: root
  } do
    invalid = exclusion("lib/a.ex")
    write_inventory(root, ["lib/a.ex"], [invalid])
    git!(root, ["add", "."])
    assert {output, 1} = run_inventory(root)
    assert "maintained-source-excluded" in decode_output(output)["errors"]

    write_inventory(root, ["lib/a.ex", "lib/a.ex"], [])
    git!(root, ["add", "."])
    assert {output, 1} = run_inventory(root)
    assert "maintained-list-not-sorted-unique" in decode_output(output)["errors"]

    unknown = Map.put(exclusion("specs/old/probe.exs"), "category", "generated")
    write_inventory(root, ["lib/a.ex"], [unknown])
    git!(root, ["add", "."])
    assert {output, 1} = run_inventory(root)
    assert "invalid-exclusion-record" in decode_output(output)["errors"]

    empty_reason = Map.put(exclusion("specs/old/probe.exs"), "reason", " ")
    write_inventory(root, ["lib/a.ex"], [empty_reason])
    git!(root, ["add", "."])
    assert {output, 1} = run_inventory(root)
    assert "invalid-exclusion-record" in decode_output(output)["errors"]

    write_inventory(root, ["../escape.ex", "lib/a.ex"], [])
    git!(root, ["add", "."])
    assert {output, 1} = run_inventory(root)
    assert "invalid-maintained-path" in decode_output(output)["errors"]
  end

  test "missing and stale inventory membership fail", %{root: root} do
    write_inventory(root, [], [])
    git!(root, ["add", "."])
    assert {output, 1} = run_inventory(root)
    assert "maintained-inventory-mismatch" in decode_output(output)["errors"]

    File.rm!(Path.join(root, "lib/a.ex"))
    git!(root, ["rm", "-q", "lib/a.ex"])
    write_inventory(root, ["lib/a.ex"], [])
    git!(root, ["add", "."])
    assert {output, 1} = run_inventory(root)
    assert "maintained-inventory-mismatch" in decode_output(output)["errors"]
  end

  test "renamed tracked source is stale until inventory is deliberately refreshed", %{root: root} do
    File.rename!(Path.join(root, "lib/a.ex"), Path.join(root, "lib/renamed.ex"))
    git!(root, ["rm", "-q", "lib/a.ex"])
    git!(root, ["add", "lib/renamed.ex"])
    assert {output, 1} = run_inventory(root)
    assert "maintained-inventory-mismatch" in decode_output(output)["errors"]

    assert {_output, 0} = run_inventory(root, ["--write-inventory"])
    inventory = Jason.decode!(File.read!(Path.join(root, "config/credo_inventory.json")))
    assert inventory["maintained"] == [".credo.exs", ".formatter.exs", "lib/renamed.ex"]
  end

  test "invalid source and Credo findings cannot be published as complete", %{root: root} do
    File.write!(Path.join(root, "lib/a.ex"), "defmodule FixtureA do\n  def broken( do\nend\n")
    git!(root, ["add", "."])
    assert {output, 1} = run_inventory(root)
    refute decode_output(output)["complete"]
  end

  test "a completed Credo analysis with default-priority findings remains complete and fails", %{
    root: root
  } do
    File.write!(
      Path.join(root, "lib/a.ex"),
      "defmodule FixtureA do\n  def value, do: IO.inspect(:value)\nend\n"
    )

    git!(root, ["add", "."])

    assert {output, 1} = run_inventory(root)
    evidence = decode_output(output)
    assert evidence["complete"]
    assert evidence["oracle_exit_status"] != 0
    assert evidence["effective"] == evidence["maintained"]
  end

  test "a Credo input outside the tracked inventory fails effective-input equality", %{root: root} do
    File.write!(
      Path.join(root, "lib/untracked.ex"),
      "defmodule UntrackedFixture do\n  @moduledoc false\nend\n"
    )

    assert {output, 1} = run_inventory(root)
    assert "effective-input-mismatch" in decode_output(output)["errors"]
  end

  test "snapshot digest binds tracked source, inventory, config, and lock", %{root: root} do
    File.write!(Path.join(root, "mix.lock"), "{}\n")
    git!(root, ["add", "."])
    assert {before, 0} = run_inventory(root, ["--snapshot"])

    File.write!(
      Path.join(root, "lib/a.ex"),
      "defmodule FixtureA do\n  @moduledoc false\n  def value, do: 1\nend\n"
    )

    assert {after_change, 0} = run_inventory(root, ["--snapshot"])
    refute decode_output(before)["source_digest"] == decode_output(after_change)["source_digest"]
  end

  defp run_inventory(root, args \\ []) do
    System.cmd("mix", ["run", "--no-start", @script | args],
      cd: @root,
      env: [{"MIX_ENV", "test"}, {"CREDO_INVENTORY_ROOT", root}],
      stderr_to_stdout: true
    )
  end

  defp write_inventory(root, maintained, excluded) do
    maintained = [".credo.exs", ".formatter.exs" | maintained] |> Enum.sort()

    File.write!(
      Path.join(root, "config/credo_inventory.json"),
      Jason.encode!(%{"schema_version" => 1, "maintained" => maintained, "excluded" => excluded},
        pretty: true
      )
    )
  end

  defp exclusion(path) do
    %{
      "path" => path,
      "category" => "archived-verification-evidence",
      "reason" => "Archived standalone verification probe retained as historical evidence."
    }
  end

  defp git!(root, args) do
    {output, status} = System.cmd("git", args, cd: root, stderr_to_stdout: true)
    assert status == 0, output
  end

  defp decode_output(output) do
    case Regex.run(~r/\{.*\}\s*$/s, output, capture: :all) do
      [json] -> Jason.decode!(json)
      nil -> flunk("inventory command did not emit JSON: #{output}")
    end
  end
end
