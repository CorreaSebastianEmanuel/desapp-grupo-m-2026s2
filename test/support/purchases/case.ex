defmodule FootballMarket.PurchasesCase do
  @moduledoc false
  alias FootballMarket.{Market, MarketCase, Repo}

  def fixture do
    f = Map.merge(MarketCase.private_schema(), MarketCase.fixture())
    cleanup(f.schema)
    {:ok, _} = Market.initialize_player(f.player.id)
    f
  end

  def cleanup(schema) do
    true = Regex.match?(~r/^market_test_[a-f0-9]+$/, schema)

    ExUnit.Callbacks.on_exit(fn ->
      Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
        Repo.query!("DROP SCHEMA IF EXISTS #{schema} CASCADE")
      end)
    end)
  end

  def fund(user, amount) do
    Repo.query!(
      "INSERT INTO market_credit_balances(user_id,amount,updated_at) VALUES($1,$2,now()) ON CONFLICT(user_id) DO UPDATE SET amount=excluded.amount",
      [Ecto.UUID.dump!(user.id), Decimal.new(amount)]
    )
  end

  def request(f, key \\ "purchase-key", quantity \\ 3),
    do: %{player_id: f.player.id, quantity: quantity, request_key: key}

  def actor(user),
    do: %FootballMarket.Accounts.AuthenticatedActor{
      account_id: user.id,
      authentication_method: :jwt,
      credential_id: Ecto.UUID.generate()
    }

  def purchase(f, key \\ "purchase-key", quantity \\ 3),
    do: Market.purchase(actor(f.buyer), request(f, key, quantity))

  def snapshot do
    Map.new(
      ~w(market_credit_balances market_purchases market_credit_entries market_token_transfers market_holdings),
      fn table ->
        {table,
         Repo.query!("SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text").rows}
      end
    )
  end
end
