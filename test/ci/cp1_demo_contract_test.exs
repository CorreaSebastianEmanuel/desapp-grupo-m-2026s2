defmodule FootballMarket.CP1DemoContractTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  @root Path.expand("../..", __DIR__)
  @script Path.join(@root, "scripts/cp1_demo.sh")

  setup_all do
    script = File.read!(@script) <> File.read!(Path.join(@root, "scripts/cp1_demo.exs"))
    %{script: script}
  end

  test "guards an explicitly disposable database and private owned staging", %{script: script} do
    for required <- [
          "CP1_DEMO_CONFIRM_DISPOSABLE",
          "CP1_DEMO_DATABASE_URL",
          "cp1_demo",
          "umask 077",
          "set +x",
          "mktemp -d",
          "trap cleanup",
          "rm -rf \"$owned\""
        ] do
      assert script =~ required
    end

    refute script =~ "rm -rf /"
  end

  test "runs deterministic preparation and seeding twice", %{script: script} do
    assert length(Regex.scan(~r/DevelopmentSeed.run\(\)/, script)) == 2
    assert script =~ "created: 0, reused: 44"
    assert script =~ "counts!() == second"
    assert script =~ ":httpc.request"
    assert script =~ "Accounts.login(attrs)"

    for value <- [
          "\"leagues\":5",
          "\"seasons\":5",
          "\"teams\":10",
          "\"positions\":4",
          "\"players\":20",
          "\"total\":44",
          "SEED_RELATIONSHIPS"
        ] do
      assert script =~ value
    end
  end

  test "covers user, jwt, api-key, catalog, and OpenAPI behavior IDs", %{script: script} do
    ids =
      ~w(USER_CREATE USER_DUPLICATE JWT_VALID_LOGIN JWT_INVALID_LOGIN JWT_PROTECTED_ACCESS API_KEY_ISSUE API_KEY_VERIFY API_KEY_PROTECTED_ACCESS API_KEY_REVOKE API_KEY_REVOKED_REJECTED CATALOG_LIST CATALOG_DETAIL CATALOG_CONTINUATION CATALOG_FILTER_LEAGUE CATALOG_FILTER_TEAM CATALOG_FILTER_POSITION CATALOG_FILTER_COMBINED CATALOG_EMPTY CATALOG_INVALID OPENAPI_JSON_PUBLIC OPENAPI_UI_PUBLIC OPENAPI_JWT_REQUEST OPENAPI_API_KEY_REQUEST)

    assert Enum.all?(ids, &String.contains?(script, &1))
  end

  test "releases an allowlisted bounded provider-independent receipt", %{script: script} do
    for required <- [
          "elapsed-time-boundary",
          "1200",
          "provider_access\":false",
          "unsafe-staging",
          "candidate_sha",
          "schema_version",
          "private-child-output"
        ] do
      assert script =~ required
    end

    refute script =~ "curl "
    refute script =~ "tee "
  end
end
