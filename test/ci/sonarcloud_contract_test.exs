defmodule FootballMarket.SonarCloudContractTest do
  use ExUnit.Case, async: true

  @moduletag :unit

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

  test "quality baseline prepares the pinned browser before browser-backed ExUnit tests" do
    workflow = File.read!(@baseline)

    steps = [
      "node-version: '24'",
      "cache-dependency-path: tools/openapi/package-lock.json",
      "npm ci --prefix tools/openapi",
      "playwright-core install --with-deps chromium",
      "scripts/ci_unit_tests.sh"
    ]

    positions =
      Enum.map(steps, fn step ->
        assert {position, _length} = :binary.match(workflow, step)
        position
      end)

    assert positions == Enum.sort(positions)
  end

  test "workflow covers every internal PR revision and main with least privilege" do
    workflow = File.read!(@workflow)
    baseline = File.read!(@baseline)

    assert workflow =~ ~r/on:\s*\n\s*workflow_call:\s*\n\s*workflow_dispatch:/
    assert baseline =~ "pull_request: {}"
    assert baseline =~ ~r/push:\s*\n\s*branches: \[main\]/
    assert baseline =~ "uses: ./.github/workflows/sonarcloud.yml"
    refute workflow =~ "pull_request_target"
    assert workflow =~ "permissions:\n  contents: read"
    assert workflow =~ "github.event.pull_request.head.sha || github.sha"
    assert workflow =~ "fetch-depth: 0"
    assert workflow =~ "cancel-in-progress: ${{ inputs.task069_probe != true }}"
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

    {json, 0} =
      System.cmd("ruby", [
        "-ryaml",
        "-rjson",
        "-e",
        "puts JSON.generate(YAML.safe_load(File.read(ARGV[0]), aliases: true))",
        @workflow
      ])

    document = Jason.decode!(json)
    job = document["jobs"]["sonarcloud"]
    refute Map.has_key?(job["env"], "SONAR_TOKEN")

    for step <- job["steps"] do
      refute (step["run"] || "") =~ ~r/\$\{\{\s*secrets\.SONAR_TOKEN/

      if step["name"] == "Test workspace JavaScript and generate LCOV" do
        refute Map.has_key?(step["env"] || %{}, "SONAR_TOKEN")
      end
    end
  end

  test "configuration imports measured JavaScript coverage without excluding new code" do
    properties = File.read!(@properties)
    assert properties =~ "sonar.sources=lib,assets/js"
    assert properties =~ "sonar.tests=test"
    assert properties =~ "sonar.sourceEncoding=UTF-8"
    assert properties =~ "sonar.organization=correasebastianemanuel"
    assert properties =~ "sonar.projectKey=CorreaSebastianEmanuel_desapp-grupo-m-2026s2"

    assert properties =~
             "sonar.exclusions=_build/**,deps/**,assets/vendor/**,priv/static/assets/**,priv/static/**/*-*.js,priv/static/**/*.map"

    assert properties =~ "sonar.javascript.lcov.reportPaths=cover/workspace/lcov.info"
    refute properties =~ "sonar.coverage.exclusions"
    refute properties =~ ~r/(token|password|secret)=/i
  end

  test "JavaScript tests generate coverage before the unchanged scanner quality gate" do
    workflow = File.read!(@workflow)
    {node, _} = :binary.match(workflow, "node-version: '24'")
    {coverage, _} = :binary.match(workflow, "run: node tools/openapi/workspace_coverage.mjs")
    {scanner, _} = :binary.match(workflow, "uses: SonarSource/sonarqube-scan-action@")
    assert node < coverage and coverage < scanner
    assert workflow =~ "sonar.qualitygate.wait=true"
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
    [normal, probe] = String.split(workflow, "  task069-probe:", parts: 2)
    normalized = String.downcase(workflow)
    assert workflow =~ "set -o pipefail"
    assert workflow =~ "::error title=SonarCloud %s"
    assert normalized =~ "authentication/authorization failures"
    assert normalized =~ "configuration failures"
    assert normalized =~ "service/network failures"
    refute normal =~ "continue-on-error"
    assert probe =~ "continue-on-error: true"
    assert probe =~ "Preserve scanner and quality-gate failures"
    refute workflow =~ "|| true"
    refute workflow =~ "set -x"
    refute workflow =~ ~r/echo.*SONAR_TOKEN/
    refute normal =~ ~r/GITHUB_STEP_SUMMARY.*SONAR_TOKEN/s
    refute probe =~ ~r/GITHUB_STEP_SUMMARY.*SONAR_TOKEN/s
  end

  test "TASK-069 probe is opt-in, exact-head guarded, and keeps imports out of normal analysis" do
    workflow = File.read!(@workflow)
    [normal, probe] = String.split(workflow, "  task069-probe:", parts: 2)
    guard = File.read!(Path.join(@root, "scripts/sonar_elixir_probe.py"))

    assert normal =~ "inputs.task069_probe != true"
    assert probe =~ "inputs.task069_probe == true"
    assert probe =~ "scripts/sonar_elixir_probe.py guard"
    assert probe =~ "scripts/application_coverage.py run"
    {preparation, _} = :binary.match(probe, "MIX_ENV=test mix test.prepare")
    {collection, _} = :binary.match(probe, "python3 scripts/application_coverage.py run")
    assert preparation < collection
    assert probe =~ "--ref"
    assert probe =~ "--sha"
    assert guard =~ "head.get(\"sha\") != sha"
    assert probe =~ "pullrequest.key=${{ inputs.task069_pull_request }}"
    assert probe =~ "pullrequest.branch=${{ github.ref_name }}"
    assert probe =~ "externalIssuesReportPaths=tmp/sonar-elixir-probe/external-issues.json"
    assert probe =~ "coverageReportPaths=tmp/sonar-elixir-probe/coverage.xml"
    assert probe =~ "name: Control analysis"
    assert probe =~ "name: Issue-only analysis"
    assert probe =~ "name: Coverage-only analysis"
    assert probe =~ "rm -f .scannerwork/report-task.txt"
    assert probe =~ "actions/upload-artifact@"
    assert probe =~ "Preserve scanner and quality-gate failures"
    refute normal =~ "sonar.externalIssuesReportPaths"
    refute normal =~ "sonar.coverageReportPaths"
    assert probe =~ "SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}"
    refute probe =~ ~r/--token\s+\$\{\{\s*secrets\.SONAR_TOKEN/
  end
end
