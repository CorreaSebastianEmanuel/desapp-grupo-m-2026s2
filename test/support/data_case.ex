defmodule FootballMarket.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias FootballMarket.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import FootballMarket.DataCase
    end
  end

  setup tags do
    FootballMarket.DataCase.setup_sandbox(tags)
    :ok
  end

  def setup_sandbox(tags) do
    owner = Ecto.Adapters.SQL.Sandbox.start_owner!(FootballMarket.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(owner) end)
  end

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, options} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        options |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
