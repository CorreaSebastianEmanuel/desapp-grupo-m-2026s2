defmodule FootballMarket.AccountsCase do
  use ExUnit.CaseTemplate

  alias FootballMarket.Accounts.{PasswordCredential, User}
  alias FootballMarket.Repo

  using do
    quote do
      alias FootballMarket.Accounts
      alias FootballMarket.Accounts.{PasswordCredential, User}
      alias FootballMarket.Repo
      import Ecto.Query
      import FootballMarket.DataCase
      import FootballMarket.AccountsCase
    end
  end

  def registration_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        email: "user#{System.unique_integer([:positive])}@example.test",
        password: "a secure password"
      },
      overrides
    )
  end

  def account_counts do
    %{
      users: Repo.aggregate(User, :count),
      credentials: Repo.aggregate(PasswordCredential, :count)
    }
  end
end
