defmodule FootballMarket.InfrastructureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias FootballMarket.Infrastructure.Configuration
    end
  end
end
