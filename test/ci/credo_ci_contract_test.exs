defmodule FootballMarket.CredoCiContractTest do
  use ExUnit.Case, async: false

  @moduletag :unit
  @root Path.expand("../..", __DIR__)

  test "wrapper preserves complete lists and both revisions and removes stale output" do
    with_fake_mix(fn _root, env ->
      output = Path.join(@root, "tmp/credo-ci-contract")
      File.mkdir_p!(output)
      File.write!(Path.join(output, "stale.json"), "stale")
      env = [{"CREDO_CI_OUTPUT_DIR", "tmp/credo-ci-contract"} | env]

      assert {_stdout, 0} = System.cmd("sh", ["scripts/credo_ci.sh"], cd: @root, env: env)
      refute File.exists?(Path.join(output, "stale.json"))
      evidence = Jason.decode!(File.read!(Path.join(output, "evidence.json")))
      assert evidence["status"] == "passed"
      assert evidence["complete"]
      assert evidence["revision"] == git_head()
      assert evidence["trigger_revision"] == "fixture-trigger-revision"
      assert evidence["maintained"] == ["lib/a.ex", "lib/b.ex"]
      assert evidence["effective"] == ["lib/a.ex", "lib/b.ex"]
      assert evidence["cli_exit_status"] == 0
      assert evidence["oracle_exit_status"] == 0
      assert evidence["credo_version"] == "1.7.19"
      assert evidence["limitations"] |> Enum.join(" ") =~ "absence of bugs"
      assert evidence["limitations"] |> Enum.join(" ") =~ "native Java analysis"
      assert File.read!(Path.join(output, "credo.log")) =~ "fixture credo output"
    end)
  end

  test "CLI and inventory failures independently fail the wrapper" do
    for {cli, oracle, expected} <- [{"7", "0", [7, 0]}, {"0", "9", [0, 9]}, {"7", "9", [7, 9]}] do
      with_fake_mix(fn _root, env ->
        env =
          env
          |> put_env("CREDO_CI_OUTPUT_DIR", "tmp/credo-ci-contract")
          |> put_env("FAKE_CLI_STATUS", cli)
          |> put_env("FAKE_ORACLE_STATUS", oracle)

        {_stdout, status} = System.cmd("sh", ["scripts/credo_ci.sh"], cd: @root, env: env)
        assert status == 1

        evidence =
          Jason.decode!(File.read!(Path.join(@root, "tmp/credo-ci-contract/evidence.json")))

        assert evidence["status"] == "failed"
        assert [evidence["cli_exit_status"], evidence["oracle_exit_status"]] == expected
      end)
    end
  end

  test "wrapper rejects output traversal before removing existing files" do
    with_fake_mix(fn _root, env ->
      suffix = System.unique_integer([:positive])
      relative = "tmp/credo-ci-escape-#{suffix}"
      target = Path.join(@root, relative)
      File.mkdir_p!(Path.join(@root, "tmp/credo-ci-contract"))
      File.mkdir_p!(target)
      sentinel = Path.join(target, "sentinel")
      File.write!(sentinel, "preserve")

      try do
        env =
          put_env(
            env,
            "CREDO_CI_OUTPUT_DIR",
            "tmp/credo-ci-contract/../credo-ci-escape-#{suffix}"
          )

        {_stdout, status} = System.cmd("sh", ["scripts/credo_ci.sh"], cd: @root, env: env)
        assert status == 2
        assert File.read!(sentinel) == "preserve"
      after
        File.rm_rf!(target)
      end
    end)
  end

  test "wrapper rejects a symlink output directory before replacing it" do
    with_fake_mix(fn root, env ->
      relative = "tmp/credo-ci-link-#{System.unique_integer([:positive])}"
      link = Path.join(@root, relative)
      target = Path.join(root, "preserved-output")
      File.mkdir_p!(target)
      File.ln_s!(target, link)
      sentinel = Path.join(target, "sentinel")
      File.write!(sentinel, "preserve")

      try do
        env = put_env(env, "CREDO_CI_OUTPUT_DIR", relative)
        {_stdout, status} = System.cmd("sh", ["scripts/credo_ci.sh"], cd: @root, env: env)
        assert status == 2
        assert File.lstat!(link).type == :symlink
        assert File.read!(sentinel) == "preserve"
      after
        File.rm_rf!(link)
      end
    end)
  end

  test "incomplete oracle and changed snapshots fail and retain diagnostics" do
    for env_extra <- [[{"FAKE_ORACLE_COMPLETE", "false"}], [{"FAKE_SNAPSHOT_CHANGE", "true"}]] do
      with_fake_mix(fn _root, env ->
        env =
          Enum.reduce(
            env_extra,
            put_env(env, "CREDO_CI_OUTPUT_DIR", "tmp/credo-ci-contract"),
            fn {key, value}, acc ->
              put_env(acc, key, value)
            end
          )

        {_stdout, status} = System.cmd("sh", ["scripts/credo_ci.sh"], cd: @root, env: env)
        assert status == 1

        evidence =
          Jason.decode!(File.read!(Path.join(@root, "tmp/credo-ci-contract/evidence.json")))

        assert evidence["status"] == "failed"

        if env_extra == [{"FAKE_ORACLE_COMPLETE", "false"}] do
          refute evidence["complete"]
        else
          assert "source-snapshot-changed-or-unavailable" in evidence["errors"]
        end
      end)
    end
  end

  test "workflow adds a mandatory independent step and complete always-upload artifact" do
    workflow = File.read!(Path.join(@root, ".github/workflows/quality-baseline.yml"))
    [baseline, _e2e] = String.split(workflow, "\n  end-to-end:", parts: 2)
    assert baseline =~ "- name: Credo and source inventory"
    assert baseline =~ "run: sh scripts/credo_ci.sh"
    assert baseline =~ "- name: Upload Credo evidence"
    assert baseline =~ "if: always()"
    assert baseline =~ "actions/upload-artifact@v4"
    assert baseline =~ "if-no-files-found: error"
    assert baseline =~ "retention-days: 14"
    assert baseline =~ "github.run_attempt"

    assert index(baseline, "name: Credo and source inventory") <
             index(baseline, "name: Unit tests")

    assert index(baseline, "name: Upload Credo evidence") > index(baseline, "name: Unit tests")
    refute baseline =~ "continue-on-error"
    refute workflow =~ "needs: sonar"

    assert File.read!(Path.join(@root, ".github/workflows/sonarcloud.yml")) =~
             "SonarCloud analysis and CP1 gate"
  end

  test "README and evidence state commands, scope, retention, and interpretation limits" do
    readme = File.read!(Path.join(@root, "README.md"))

    for phrase <- [
          "MIX_ENV=test mix credo --format flycheck",
          "scripts/credo_ci.sh",
          "--write-inventory",
          "staged",
          "default-priority",
          "14 days",
          "trigger_revision",
          "absence of bugs",
          "native Java analysis"
        ] do
      assert readme =~ phrase
    end
  end

  defp with_fake_mix(fun) do
    root = Path.join(System.tmp_dir!(), "credo-ci-contract-#{System.unique_integer([:positive])}")
    bin = Path.join(root, "bin")
    File.mkdir_p!(bin)

    fake_mix = """
    #!/bin/sh
    case "$*" in
      *--snapshot*)
        if [ "${FAKE_SNAPSHOT_CHANGE:-false}" = true ] && [ -f "$FAKE_COUNTER" ]; then digest=changed; else digest=fixed; fi
        touch "$FAKE_COUNTER"
        printf '{"complete":true,"source_digest":"%s"}\\n' "$digest"
        ;;
      *credo_inventory.exs*)
        printf '{"complete":%s,"maintained":["lib/a.ex","lib/b.ex"],"effective":["lib/a.ex","lib/b.ex"],"excluded":[],"source_digest":"fixed","oracle_exit_status":0}\\n' "${FAKE_ORACLE_COMPLETE:-true}"
        exit "${FAKE_ORACLE_STATUS:-0}"
        ;;
      *) echo 'fixture credo output'; exit "${FAKE_CLI_STATUS:-0}" ;;
    esac
    """

    script = Path.join(bin, "mix")
    File.write!(script, fake_mix)
    File.chmod!(script, 0o755)
    counter = Path.join(root, "counter")

    env = [
      {"PATH", bin <> ":" <> System.get_env("PATH")},
      {"FAKE_COUNTER", counter},
      {"FAKE_CLI_STATUS", "0"},
      {"FAKE_ORACLE_STATUS", "0"},
      {"GITHUB_SHA", "fixture-trigger-revision"}
    ]

    try do
      fun.(root, env)
    after
      File.rm_rf!(root)
      File.rm_rf!(Path.join(@root, "tmp/credo-ci-contract"))
    end
  end

  defp index(contents, needle) do
    {offset, _length} = :binary.match(contents, needle)
    offset
  end

  defp put_env(env, key, value),
    do: [{key, value} | Enum.reject(env, fn {name, _} -> name == key end)]

  defp git_head do
    {head, 0} = System.cmd("git", ["rev-parse", "HEAD"], cd: @root)
    String.trim(head)
  end
end
