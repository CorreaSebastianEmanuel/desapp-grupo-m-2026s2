defmodule FootballMarket.TestProfileRunnerContractTest do
  use ExUnit.Case, async: false

  @moduletag :unit
  @root Path.expand("../..", __DIR__)

  test "runner selects exactly one profile, includes performance tests, and releases only safe receipts" do
    launcher = File.read!(Path.join(@root, "scripts/test_profile.sh"))
    runner = File.read!(Path.join(@root, "scripts/test_profile_runner.py"))
    assert launcher =~ "umask 077"
    assert launcher =~ "exec python3 scripts/test_profile_runner.py"
    assert runner =~ "'--include', 'performance', '--only', profile"
    assert runner =~ "CP1_PROFILE_RECEIPT"
    assert runner =~ "start_new_session=True"
    assert runner =~ "signal.SIGKILL"
    assert runner =~ "TemporaryFile"
    assert runner =~ "reconcile(expected, mapped)"
    assert runner =~ "inventory_digest=digest"
    assert runner =~ "chromium.launch"
    refute runner =~ "print(output"
    refute runner =~ "node_modules/playwright\")"
  end

  test "browser harness and ExUnit bridge use opaque receipts" do
    browser = File.read!(Path.join(@root, "tools/openapi/browser.mjs"))
    bridge = File.read!(Path.join(@root, "test/football_market_web/openapi_browser_test.exs"))

    assert browser =~ "CP1_BROWSER_RECEIPT status=complete"
    refute browser =~ "error.message"
    refute bridge =~ "IO.puts(output)"
    refute bridge =~ "assert status == 0, output"
  end

  test "controlled child failure releases no stdout stderr password token key or hash" do
    script = """
    import contextlib,io,os,sys
    sys.path.insert(0,'scripts')
    from test_profile_runner import run
    captured=io.StringIO()
    try:
      with contextlib.redirect_stdout(captured),contextlib.redirect_stderr(captured):
        run([sys.executable,'-c',"import sys;print('password-token-key-hash');print('password-token-key-hash',file=sys.stderr);raise SystemExit(7)"],os.environ.copy(),2)
      raise AssertionError('child accepted')
    except ValueError:
      assert captured.getvalue()==''
    """

    assert {"", 0} = System.cmd("python3", ["-c", script], stderr_to_stdout: true)
  end

  test "controlled browser failure forwards only its allowlisted stage" do
    script = """
    import contextlib,io,os,sys
    sys.path.insert(0,'scripts')
    from test_profile_runner import run
    captured=io.StringIO()
    try:
      with contextlib.redirect_stdout(captured),contextlib.redirect_stderr(captured):
        run([sys.executable,'-c',"import sys;print('PROFILE_SAFE_DIAGNOSTIC category=openapi-browser stage=docs-ready');print('credential-secret',file=sys.stderr);raise SystemExit(7)"],os.environ.copy(),2)
      raise AssertionError('child accepted')
    except ValueError:
      assert captured.getvalue()=='PROFILE_SAFE_DIAGNOSTIC category=openapi-browser stage=docs-ready\\n'
    """

    assert {"", 0} = System.cmd("python3", ["-c", script], stderr_to_stdout: true)
  end

  test "CI failure reporting forwards only allowlisted profile diagnostics" do
    script = File.read!(Path.join(@root, "scripts/ci_unit_tests.sh"))
    assert script =~ "PROFILE_SAFE_DIAGNOSTIC category=openapi-browser stage=[a-z-]+"
    assert script =~ "PROFILE_DISCREPANCY id=[0-9a-f]{24}"
    assert script =~ "CP1_PROFILE_OUTCOME status=failed category=[a-z-]+"
    refute script =~ "cat \"$private/output\""
  end

  test "formatter records unexpected profile execution with the invocation nonce" do
    path = Path.join(System.tmp_dir!(), "formatter-" <> Ecto.UUID.generate())
    original = System.get_env("PROFILE_EVENTS")
    original_nonce = System.get_env("PROFILE_NONCE")
    System.put_env("PROFILE_EVENTS", path)
    System.put_env("PROFILE_NONCE", "controlled-nonce")

    try do
      {:ok, formatter} = FootballMarket.TestProfileFormatter.start_link([])
      System.put_env("PROFILE_NONCE", "changed-after-formatter-start")

      test = %ExUnit.Test{
        module: UnexpectedIntegration,
        name: :"test unexpected",
        tags: %{file: "test/unexpected_test.exs", integration: true}
      }

      GenServer.cast(formatter, {:test_started, test})
      GenServer.cast(formatter, {:test_finished, test})
      :sys.get_state(formatter)
      GenServer.stop(formatter)

      events =
        path |> File.read!() |> String.split("\n", trim: true) |> Enum.map(&Jason.decode!/1)

      assert Enum.map(events, & &1["state"]) == ["started", "passed"]
      assert Enum.all?(events, &(&1["nonce"] == "controlled-nonce"))
    after
      File.rm(path)

      if original,
        do: System.put_env("PROFILE_EVENTS", original),
        else: System.delete_env("PROFILE_EVENTS")

      if original_nonce,
        do: System.put_env("PROFILE_NONCE", original_nonce),
        else: System.delete_env("PROFILE_NONCE")
    end
  end
end
