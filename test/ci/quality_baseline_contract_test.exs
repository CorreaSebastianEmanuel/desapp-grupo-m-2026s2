defmodule FootballMarket.QualityBaselineContractTest do
  use ExUnit.Case, async: true

  @root Path.expand("../..", __DIR__)
  @workflow Path.join(@root, ".github/workflows/quality-baseline.yml")
  @readme Path.join(@root, "README.md")

  setup_all do
    ruby = """
    require "yaml"
    require "json"
    document = YAML.safe_load(File.read(ARGV.fetch(0)), aliases: true)
    document["on"] ||= document.delete(true)
    puts JSON.generate(document)
    """

    {json, 0} = System.cmd("ruby", ["-e", ruby, @workflow], stderr_to_stdout: true)
    {:ok, workflow_document: Jason.decode!(json)}
  end

  test "workflow gates main pull requests and pushes in one least-privilege job", context do
    workflow = File.read!(@workflow)
    document = context.workflow_document

    assert document["on"]["pull_request"]["branches"] == ["main"]
    assert document["on"]["push"]["branches"] == ["main"]
    assert document["permissions"] == %{"contents" => "read"}
    assert map_size(document["jobs"]) == 1
    assert document["jobs"]["quality-baseline"]["runs-on"] == "ubuntu-24.04"

    assert Enum.count(
             document["jobs"]["quality-baseline"]["steps"],
             &(&1["uses"] == "actions/checkout@v4")
           ) == 1

    assert workflow =~ "cancel-in-progress: true"
    assert workflow =~ "github.event.pull_request.number || github.ref"
    assert workflow =~ "elixir-version: '1.20.3'"
    assert workflow =~ "otp-version: '29.0.6'"

    assert workflow =~
             "key: ${{ runner.os }}-otp-29.0.6-elixir-1.20.3-${{ hashFiles('mix.lock') }}"

    assert workflow =~ "postgres:16"
    assert workflow =~ "pg_isready -U postgres -d football_market_test"
    assert workflow =~ "mix deps.get --locked"
    assert workflow =~ "run: MIX_ENV=test mix deps.compile"
  end

  test "workflow exposes exactly three ordered quality categories with bounded commands" do
    workflow = File.read!(@workflow)

    labels =
      Regex.scan(~r/^\s+- name: (Formatting|Warnings-as-errors|Unit tests)$/m, workflow,
        capture: :all_but_first
      )
      |> List.flatten()

    assert labels == ["Formatting", "Warnings-as-errors", "Unit tests"]
    assert workflow =~ "run: mix format --check-formatted"
    assert workflow =~ "run: MIX_ENV=test mix compile --warnings-as-errors"
    assert workflow =~ "run: scripts/ci_unit_tests.sh"
    refute workflow =~ ~r/(secrets\.|redis|sonar|coverage|deploy|release|e2e|architecture)/i
    refute workflow =~ ~r/mix format\s*$/m
    refute workflow =~ ~r/mix test.*(--stale|--only|--exclude|test\/)/
  end

  test "workflow has no source-mutating or success-masking quality commands" do
    workflow = File.read!(@workflow)

    refute workflow =~ "continue-on-error"
    refute workflow =~ "|| true"
    refute workflow =~ "git add"
    refute workflow =~ "git commit"
  end

  test "README documents prerequisites and the three locally equivalent commands" do
    readme = File.read!(@readme)

    assert readme =~ "Elixir 1.20.3"
    assert readme =~ "Erlang/OTP 29.0.6"
    assert readme =~ "PostgreSQL"
    assert readme =~ "./scripts/check_toolchain.sh"
    assert readme =~ "mix format --check-formatted"
    assert readme =~ "MIX_ENV=test mix compile --warnings-as-errors"
    assert readme =~ "scripts/ci_unit_tests.sh"
  end
end
