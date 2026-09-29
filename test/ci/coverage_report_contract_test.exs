defmodule FootballMarket.CoverageReportContractTest do
  use ExUnit.Case, async: true

  @moduletag :unit
  @root Path.expand("../..", __DIR__)

  test "coverage publication binds a stable working-tree snapshot and publishes only complete safe reports" do
    runner = File.read!(Path.join(@root, "scripts/coverage_report.sh"))

    assert runner =~ "git diff --binary --full-index HEAD"
    assert runner =~ "snapshot_paths()"
    assert runner =~ ":(exclude)specs/014-cp1-test-coverage-profiles/qa-report.md"
    assert runner =~ ":(exclude)specs/014-cp1-test-coverage-profiles/review-report.md"
    assert runner =~ ":(exclude)specs/014-cp1-test-coverage-profiles/handoffs"
    assert runner =~ "working-tree snapshot"
    assert runner =~ "committed revision"
    assert runner =~ "non-generated-untracked-input"
    assert runner =~ "scripts/test_profile.sh unit"
    assert runner =~ "scripts/test_profile.sh integration"
    assert runner =~ "CP1_PROFILE_COVERAGE=1"
    assert runner =~ "CP1_PROFILE_RECEIPT"
    assert runner =~ "native_coverage=\"$staging/native\""
    assert runner =~ "CP1_COVERAGE_OUTPUT=\"$native_coverage\" CP1_PROFILE_COVERAGE=1"
    assert runner =~ "Mix.Tasks.Test.Coverage.run([])"
    assert runner =~ "FootballMarket.CP1CoveragePublisher.publish!"
    assert runner =~ "manifest.json"
    assert runner =~ "inventory_sha256"
    publisher = File.read!(Path.join(@root, "test/support/cp1_coverage_publisher.ex"))
    assert publisher =~ "generated_at"
    assert publisher =~ "report.metadata.snapshot_label"
    assert runner =~ "CP1_PROFILE_(SECRET|HASH)_SENTINEL"
    assert runner =~ "mv \"$staging\" \"$final\""
    refute runner =~ "requires a clean HEAD"
  end
end
