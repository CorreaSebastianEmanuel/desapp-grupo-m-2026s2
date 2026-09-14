defmodule FootballMarket.Infrastructure.DatabaseWorkflowTest do
  use ExUnit.Case, async: true

  test "all mutation entry points share the guard" do
    source = File.read!("lib/mix/tasks/infrastructure.database.ex")
    assert length(Regex.scan(~r/guard!\(\)/, source)) >= 3
    assert source =~ "already_up"
  end
end
