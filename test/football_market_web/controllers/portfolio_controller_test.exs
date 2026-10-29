defmodule FootballMarketWeb.PortfolioControllerTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  alias FootballMarket.{Accounts, PurchasesCase}
  @endpoint FootballMarketWeb.Endpoint

  setup do
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.buyer, "100")

    {:ok, {:ok, key}} =
      FootballMarket.Repo.transaction(fn -> Accounts.issue_api_key(f.buyer.id) end)

    {:ok, jwt} = Accounts.Authentication.issue(f.buyer.id)
    Map.merge(f, %{secret: key.secret, jwt: jwt})
  end

  test "both credentials return private owner analytics with decimal strings and UTC metadata",
       f do
    assert {:ok, _} = PurchasesCase.purchase(f, "api-analytics", 3)
    conn = request(f, "/api/portfolio/allocation")
    assert get_resp_header(conn, "cache-control") == ["private, no-store"]

    assert %{"data" => %{"positions" => [position], "totals" => totals, "as_of" => as_of}} =
             json_response(conn, 200)

    assert position["quantity"] == 3
    assert Decimal.equal?(Decimal.new(position["market_value"]), "3")
    assert position["quote"]["unit_price"] == "1.00"
    assert is_binary(totals["total_profit_loss"])
    assert {:ok, _, 0} = DateTime.from_iso8601(as_of)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> f.jwt)
      |> get("/api/portfolio/history")

    points = json_response(conn, 200)["data"]["points"]
    assert length(points) == 30
    assert List.last(points)["partial"]
    assert Decimal.equal?(Decimal.new(List.last(points)["purchase_expenditure"]), "3")
  end

  test "malformed dates reject after authentication and owner parameters cannot change scope",
       f do
    assert {:ok, _} = PurchasesCase.purchase(f, "api-owner", 1)

    for query <- [
          "from=",
          "from=2025-02-29",
          "from=x&from=y",
          "to[]=2026-01-01",
          "from[x]=2026-01-01"
        ] do
      assert json_response(request(f, "/api/portfolio/history?" <> query), 400)["error"]["code"] ==
               "invalid_date"
    end

    assert json_response(request(f, "/api/portfolio/history?from=2026-01-02&to=2026-01-01"), 400)[
             "error"
           ]["code"] == "invalid_date_range"

    body = request(f, "/api/portfolio/allocation?owner_id=#{f.owner.id}") |> json_response(200)
    assert length(body["data"]["positions"]) == 1

    for path <- ["/api/portfolio/allocation", "/api/portfolio/history?from=invalid"] do
      assert build_conn() |> get(path) |> json_response(401) == %{
               "error" => %{"code" => "unauthenticated"}
             }

      assert build_conn()
             |> put_req_header("authorization", "Bearer invalid")
             |> get(path)
             |> json_response(401) == %{"error" => %{"code" => "unauthenticated"}}
    end
  end

  test "empty accounts return complete zero-valued data and one-sided ranges work", f do
    today = Date.utc_today()
    date = Date.to_iso8601(today)

    assert %{
             "data" => %{
               "positions" => [],
               "totals" => %{"valuation_complete" => true, "market_value" => "0"}
             }
           } = json_response(request(f, "/api/portfolio/allocation"), 200)

    assert [%{"partial" => true, "date" => ^date}] =
             json_response(request(f, "/api/portfolio/history?from=#{date}"), 200)["data"][
               "points"
             ]

    assert length(
             json_response(request(f, "/api/portfolio/history?to=#{date}"), 200)["data"]["points"]
           ) == 30
  end

  test "storage errors are sanitized and private for both analytics responses", f do
    FootballMarket.Repo.query!("ALTER TABLE market_purchases RENAME TO unavailable_purchases")

    try do
      for path <- ["/api/portfolio/allocation", "/api/portfolio/history"] do
        conn = request(f, path)
        assert json_response(conn, 503) == %{"error" => %{"code" => "temporarily_unavailable"}}
        assert get_resp_header(conn, "cache-control") == ["private, no-store"]
      end
    after
      FootballMarket.Repo.query!("ALTER TABLE unavailable_purchases RENAME TO market_purchases")
    end
  end

  defp request(f, path), do: build_conn() |> put_req_header("x-api-key", f.secret) |> get(path)
end
