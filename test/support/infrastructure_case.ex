defmodule FootballMarket.InfrastructureCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      alias FootballMarket.Infrastructure.Configuration
    end
  end
end
