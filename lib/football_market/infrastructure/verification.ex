defmodule FootballMarket.Infrastructure.Verification do
  @moduledoc false

  def exit_status(results),
    do: if(Enum.count(results) == 2 and Enum.all?(results, &(&1.status == :ok)), do: 0, else: 1)

  def render(results) do
    results
    |> Enum.map(fn result ->
      label = if result.dependency == :postgresql, do: "PostgreSQL", else: "Redis"

      status =
        case result.status do
          :ok -> "OK"
          {:error, category} -> "ERROR #{category}"
        end

      "#{label}: #{status} (#{result.target})"
    end)
    |> Enum.join("\n")
  end
end
