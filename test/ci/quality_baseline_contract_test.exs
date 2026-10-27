defmodule FootballMarket.QualityBaselineContractTest do
  use ExUnit.Case, async: true

  @moduletag :unit

  @root Path.expand("../..", __DIR__)
  @workflow Path.join(@root, ".github/workflows/quality-baseline.yml")
  @readme Path.join(@root, "README.md")
  @compose Path.join(@root, "compose.yaml")
  @postgres_image "postgres:17.6-alpine@sha256:ef257d85f76e48da1c64832459b59fcaba1a4dac97bf5d7450c77753542eee94"

  @redis_image "redis:8.2.1-alpine@sha256:987c376c727652f99625c7d205a1cba3cb2c53b92b0b62aade2bd48ee1593232"

  setup_all do
    ruby = """
    require "yaml"
    require "json"
    document = YAML.safe_load(File.read(ARGV.fetch(0)), aliases: true)
    document["on"] ||= document.delete(true)
    puts JSON.generate(document)
    """

    {json, 0} = System.cmd("ruby", ["-e", ruby, @workflow], stderr_to_stdout: true)
    {compose_json, 0} = System.cmd("ruby", ["-e", ruby, @compose], stderr_to_stdout: true)

    {:ok, workflow_document: Jason.decode!(json), compose_document: Jason.decode!(compose_json)}
  end

  test "CI PostgreSQL uses the exact planned local service image", context do
    image = context.workflow_document["jobs"]["quality-baseline"]["services"]["postgres"]["image"]
    assert image == @postgres_image
    assert image == context.compose_document["services"]["postgres"]["image"]
  end

  test "CI Redis uses the pinned local image, test port and bounded health readiness", context do
    services = context.workflow_document["jobs"]["quality-baseline"]["services"]
    assert Enum.sort(Map.keys(services)) == ["postgres", "redis"]
    redis = services["redis"]
    assert is_map(redis)
    assert redis["image"] == @redis_image
    assert redis["image"] == context.compose_document["services"]["redis"]["image"]
    assert redis["ports"] == ["6379:6379"]
    assert Application.fetch_env!(:football_market, :redis)[:port] == 6379

    assert String.split(redis["options"]) == [
             "--health-cmd",
             "\"redis-cli",
             "ping\"",
             "--health-interval",
             "10s",
             "--health-timeout",
             "5s",
             "--health-retries",
             "5"
           ]
  end

  test "workflow gates main pull requests and pushes in least-privilege jobs", context do
    workflow = File.read!(@workflow)
    document = context.workflow_document

    assert document["on"]["pull_request"]["branches"] == ["main"]
    assert document["on"]["push"]["branches"] == ["main"]
    assert document["permissions"] == %{"contents" => "read"}

    assert Enum.sort(Map.keys(document["jobs"])) == [
             "end-to-end",
             "quality-baseline",
             "sonarcloud",
             "thinflow-required"
           ]

    assert document["jobs"]["quality-baseline"]["runs-on"] == "ubuntu-24.04"
    assert document["jobs"]["sonarcloud"]["uses"] == "./.github/workflows/sonarcloud.yml"

    assert Enum.sort(document["jobs"]["thinflow-required"]["needs"]) == [
             "end-to-end",
             "quality-baseline",
             "sonarcloud"
           ]

    assert document["jobs"]["thinflow-required"]["if"] == "always()"

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

    assert workflow =~ "pg_isready -U postgres -d football_market_test"
    assert workflow =~ "mix deps.get --locked"
    assert workflow =~ "run: MIX_ENV=test mix deps.compile"
  end

  test "workflow exposes exactly three ordered quality categories with bounded commands" do
    workflow = File.read!(@workflow) |> String.split("  end-to-end:") |> hd()

    labels =
      Regex.scan(~r/^\s+- name: (Formatting|Warnings-as-errors|Unit tests)$/m, workflow,
        capture: :all_but_first
      )
      |> List.flatten()

    assert labels == ["Formatting", "Warnings-as-errors", "Unit tests"]
    assert workflow =~ "run: mix format --check-formatted"
    assert workflow =~ "run: MIX_ENV=test mix compile --warnings-as-errors"
    assert workflow =~ "run: scripts/ci_unit_tests.sh"
    assert workflow =~ "playwright-core install --with-deps chromium"
    refute workflow =~ "playwright-core install --with-deps --only-shell chromium"
    assert workflow =~ "name: Workflow behavior tests"
    assert workflow =~ "verify-receipts tmp/profile-ci"
    assert workflow =~ "fetch-depth: 0"
    refute workflow =~ ~r/(secrets\.|sonar|coverage|deploy|release|architecture)/i
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

  test "Credo reconciliation is mandatory and retains full evidence independently", context do
    workflow = File.read!(@workflow)
    [baseline, _e2e] = String.split(workflow, "\n  end-to-end:", parts: 2)
    credo = index(baseline, "name: Credo and source inventory")
    tests = index(baseline, "name: Unit tests")
    upload = index(baseline, "name: Upload Credo evidence")

    assert credo != nil and tests != nil and upload != nil
    assert credo < tests
    assert upload > tests
    assert baseline =~ "run: sh scripts/credo_ci.sh"
    assert baseline =~ "if: always()"
    assert baseline =~ "actions/upload-artifact@v4"
    assert baseline =~ "if-no-files-found: error"
    assert baseline =~ "retention-days: 14"
    assert baseline =~ "github.run_attempt"
    refute baseline =~ "continue-on-error"
    refute baseline =~ "needs: sonar"

    steps = context.workflow_document["jobs"]["quality-baseline"]["steps"]
    credo_step = Enum.find(steps, &(&1["name"] == "Credo and source inventory"))
    upload_step = Enum.find(steps, &(&1["name"] == "Upload Credo evidence"))
    assert credo_step["run"] == "sh scripts/credo_ci.sh"
    assert upload_step["if"] == "always()"
    assert upload_step["uses"] == "actions/upload-artifact@v4"
    assert upload_step["with"]["path"] == "tmp/credo-ci/"
    assert upload_step["with"]["retention-days"] == 14
    assert upload_step["with"]["if-no-files-found"] == "error"
    assert upload_step["with"]["name"] =~ "github.sha"
    assert upload_step["with"]["name"] =~ "github.run_attempt"
  end

  defp index(contents, needle) do
    {offset, _length} = :binary.match(contents, needle)
    offset
  end

  test "README documents prerequisites and the three locally equivalent commands" do
    readme = File.read!(@readme)

    assert readme =~ "Elixir 1.20.3"
    assert readme =~ "Erlang/OTP 29.0.6"
    assert readme =~ "PostgreSQL"
    assert readme =~ "Redis"
    assert readme =~ "./scripts/check_toolchain.sh"
    assert readme =~ "mix format --check-formatted"
    assert readme =~ "MIX_ENV=test mix compile --warnings-as-errors"
    assert readme =~ "scripts/ci_unit_tests.sh"
  end

  test "CP1 tooling remains outside the locked baseline" do
    workflow = File.read!(@workflow)
    runner = File.read!(Path.join(@root, "scripts/ci_unit_tests.sh"))

    assert workflow =~ "scripts/test_profile.sh e2e"
    refute workflow =~ "cp1_coverage"
    assert runner =~ "scripts/test_profile.sh"
    assert runner =~ "PROFILE_MEMBERSHIP_DIAGNOSTIC"
    refute runner =~ "print(output"
  end
end
