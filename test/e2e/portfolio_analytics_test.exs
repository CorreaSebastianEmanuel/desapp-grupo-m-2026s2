defmodule FootballMarket.E2E.PortfolioAnalyticsTest do
  use ExUnit.Case, async: false
  @moduletag :e2e
  @tag timeout: 170_000
  alias FootballMarket.{Accounts, Market, MarketCase, PurchasesCase, SalesCase}

  test "real authenticated HTTP reports persisted trading value and flows without mutating state" do
    original = Application.fetch_env(:football_market, :initial_issuance_recipients)

    try do
      FootballMarket.E2E.Runtime.with_runtime!(fn base ->
        f = MarketCase.fixture()
        assert {:ok, _} = Market.initialize_player(f.player.id)
        PurchasesCase.fund(f.buyer, "100")
        PurchasesCase.fund(f.owner, "100")
        assert {:ok, _} = PurchasesCase.purchase(f, "analytics-runtime-buy", 3)
        assert {:ok, _} = SalesCase.sale(f, "analytics-runtime-sale", 1)
        {:ok, jwt} = Accounts.Authentication.issue(f.buyer.id)
        {:ok, owner_jwt} = Accounts.Authentication.issue(f.owner.id)
        before = {SalesCase.snapshot(), MarketCase.snapshot()}

        assert {401, _} = get(base, "/api/portfolio/history?from=invalid", nil)
        assert {200, %{"data" => allocation}} = get(base, "/api/portfolio/allocation", jwt)
        assert [position] = allocation["positions"]
        assert position["quantity"] == 2
        assert position["quote"]["unit_price"] == "1.00"
        assert Decimal.equal?(allocation["totals"]["market_value"], "2")
        assert Decimal.equal?(allocation["totals"]["purchase_expenditure"], "3")
        assert Decimal.equal?(allocation["totals"]["sale_proceeds"], "1")
        assert Decimal.equal?(allocation["totals"]["total_profit_loss"], "0")

        assert {200, %{"data" => %{"positions" => []}}} =
                 get(base, "/api/portfolio/allocation", owner_jwt)

        today = Date.to_iso8601(Date.utc_today())

        assert {200, %{"data" => %{"points" => [point]}}} =
                 get(base, "/api/portfolio/history?from=#{today}", jwt)

        assert point["partial"]
        assert Decimal.equal?(point["market_value"], "2")
        assert before == {SalesCase.snapshot(), MarketCase.snapshot()}
      end)
    after
      case original do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end
  end

  defp get(base, path, jwt) do
    headers = if jwt, do: [{~c"authorization", String.to_charlist("Bearer " <> jwt)}], else: []

    assert {:ok, {{_, status, _}, _, body}} =
             :httpc.request(:get, {String.to_charlist(base <> path), headers}, [timeout: 5_000],
               body_format: :binary
             )

    {status, Jason.decode!(body)}
  end
end
