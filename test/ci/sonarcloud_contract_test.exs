defmodule FootballMarket.SonarCloudContractTest do
  use ExUnit.Case, async: true

  @root Path.expand("../..", __DIR__)
  @workflow Path.join(@root, ".github/workflows/sonarcloud.yml")
  @baseline Path.join(@root, ".github/workflows/quality-baseline.yml")
  @properties Path.join(@root, "sonar-project.properties")

  test "TASK-003 workflow matches its byte oracle and remains discoverable" do
    [expected | _] =
      @root
      |> Path.join("test/ci/fixtures/quality-baseline.sha256")
      |> File.read!()
      |> String.split()

    actual = :crypto.hash(:sha256, File.read!(@baseline)) |> Base.encode16(case: :lower)
    assert actual == expected
    assert File.read!(@baseline) =~ "name: Quality baseline"
  end

  test "workflow covers every internal PR revision and main with least privilege" do
    workflow = File.read!(@workflow)

    assert workflow =~
             ~r/pull_request:\s*\n\s*branches: \[main\]\s*\n\s*types: \[opened, synchronize, reopened, ready_for_review\]/

    assert workflow =~ ~r/push:\s*\n\s*branches: \[main\]/
    refute workflow =~ "pull_request_target"
    assert workflow =~ "permissions:\n  contents: read"
    assert workflow =~ "github.event.pull_request.head.sha || github.sha"
    assert workflow =~ "fetch-depth: 0"
    assert workflow =~ "cancel-in-progress: true"
    assert workflow =~ "github.event.pull_request.number || github.ref"
  end

  test "actions are immutable, scanning waits boundedly, and token stays indirect" do
    workflow = File.read!(@workflow)

    pins =
      Regex.scan(~r/uses:\s+[^\s@]+@([^\s]+)/, workflow, capture: :all_but_first)
      |> List.flatten()

    assert pins != []
    assert Enum.all?(pins, &Regex.match?(~r/^[0-9a-f]{40}$/, &1))
    assert workflow =~ "SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}"
    assert workflow =~ "sonar.qualitygate.wait=true"
    assert workflow =~ "sonar.qualitygate.timeout=300"
    refute workflow =~ "sonar.verbose=true"
    refute workflow =~ ~r/run:.*\$\{\{\s*secrets\.SONAR_TOKEN/s
  end

  test "configuration has exact owned scope and no coverage setting" do
    properties = File.read!(@properties)
    assert properties =~ "sonar.sources=lib,assets/js"
    assert properties =~ "sonar.tests=test"
    assert properties =~ "sonar.sourceEncoding=UTF-8"
    assert properties =~ "sonar.organization=correasebastianemanuel"
    assert properties =~ "sonar.projectKey=CorreaSebastianEmanuel_desapp-grupo-m-2026s2"

    assert properties =~
             "sonar.exclusions=_build/**,deps/**,assets/vendor/**,priv/static/assets/**,priv/static/**/*-*.js,priv/static/**/*.map"

    refute properties =~ ~r/coverage/i
    refute properties =~ ~r/(token|password|secret)=/i
  end

  test "gate separates PR and main freshness and exposes distinct summaries" do
    workflow = File.read!(@workflow)
    gate = File.read!(Path.join(@root, "scripts/sonar_checkpoint_gate.py"))
    assert workflow =~ "--mode \"$ANALYSIS_MODE\""
    assert workflow =~ "--expected-revision \"$EXPECTED_REVISION\""
    assert gate =~ "/api/project_analyses/search"
    assert gate =~ "/api/measures/component"
    assert gate =~ ~s{"metricKeys": "open_issues"}
    assert workflow =~ "Exact-head SonarCloud analysis"
    assert workflow =~ "Current primary-branch CP1 count"
    assert workflow =~ "Integrated main analysis"
    assert workflow =~ "github.event_name == 'pull_request'"
  end

  test "workflow propagates failures and does not persist or summarize secrets" do
    workflow = File.read!(@workflow)
    normalized = String.downcase(workflow)
    assert workflow =~ "set -o pipefail"
    assert workflow =~ "::error title=SonarCloud %s"
    assert normalized =~ "authentication/authorization failures"
    assert normalized =~ "configuration failures"
    assert normalized =~ "service/network failures"
    refute workflow =~ "continue-on-error"
    refute workflow =~ "|| true"
    refute workflow =~ "set -x"
    refute workflow =~ ~r/echo.*SONAR_TOKEN/
    refute workflow =~ ~r/GITHUB_STEP_SUMMARY.*SONAR_TOKEN/s
  end
end
