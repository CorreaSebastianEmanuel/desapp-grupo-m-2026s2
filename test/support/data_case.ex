defmodule FootballMarket.DataCase do
  @moduledoc false
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
    options =
      [shared: not tags[:async]]
      |> Keyword.put(:ownership_timeout, tags[:ownership_timeout] || 120_000)

    owner = Ecto.Adapters.SQL.Sandbox.start_owner!(FootballMarket.Repo, options)
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(owner) end)
  end

  # The synchronous fixtures share migration modules but own their schemas and data.
  def migrate_private_schema!(schema) do
    Ecto.Migrator.run(FootballMarket.Repo, private_schema_migrations(), :up,
      all: true,
      prefix: schema,
      log: false
    )
  end

  defp private_schema_migrations do
    key = {__MODULE__, :private_schema_migrations}

    case :persistent_term.get(key, nil) do
      nil ->
        migrations = compile_private_schema_migrations()
        :persistent_term.put(key, migrations)
        migrations

      migrations ->
        migrations
    end
  end

  defp compile_private_schema_migrations do
    previous = Code.compiler_options(ignore_module_conflict: true)

    try do
      for path <- Path.wildcard("priv/repo/migrations/**/*.exs") do
        {version, "_" <> _} = path |> Path.basename() |> Integer.parse()

        migration =
          path
          |> Code.compile_file()
          |> Enum.find(fn {module, _} -> function_exported?(module, :__migration__, 0) end)

        {module, _} = migration || raise Ecto.MigrationError, "no migration in #{path}"
        {version, module}
      end
    after
      Code.compiler_options(previous)
    end
  end

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, options} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        options |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
