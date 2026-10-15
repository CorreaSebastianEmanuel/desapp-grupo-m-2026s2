defmodule FootballMarket.Synchronization.Clock do
  @moduledoc "UTC production clock."
  @test Mix.env() == :test
  def now,
    do:
      if(@test,
        do:
          Process.get(
            :synchronization_now,
            Keyword.get(
              Application.get_env(:football_market, FootballMarket.Synchronization, []),
              :test_now,
              DateTime.utc_now()
            )
          ),
        else: DateTime.utc_now()
      )
end
