defmodule FootballMarket.Repo do
  use Ecto.Repo,
    otp_app: :football_market,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Executes `fun` inside a fresh `REPEATABLE READ, READ ONLY` transaction snapshot.
  Returns `{:error, :in_transaction}` if called inside an existing transaction, or
  `{:error, :storage_unavailable}` on database connection/query failures.
  """
  def read_only_snapshot(fun) when is_function(fun, 0) do
    if in_transaction?() do
      {:error, :in_transaction}
    else
      transaction(fn ->
        query!("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY")
        fun.()
      end)
    end
  rescue
    _ in [DBConnection.ConnectionError, Postgrex.Error, Ecto.NoResultsError] ->
      {:error, :storage_unavailable}
  end
end
