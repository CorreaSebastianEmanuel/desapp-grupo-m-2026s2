defmodule CredoInventory do
  @inventory "config/credo_inventory.json"
  @category "archived-verification-evidence"
  @allowed_categories [@category]
  @source_roots ["lib/", "config/", "priv/", "scripts/", "test/"]

  def main(args) do
    root = System.get_env("CREDO_INVENTORY_ROOT") || File.cwd!()
    execute(root, args)
  end

  defp execute(root, args) do
    try do
      root |> dispatch(args) |> render_result()
    rescue
      error -> render_result({:error, [safe_error(error)]})
    end
  end

  defp dispatch(root, ["--snapshot"]), do: snapshot(root)
  defp dispatch(root, ["--write-inventory"]), do: write_inventory(root)
  defp dispatch(root, []), do: reconcile(root)
  defp dispatch(_root, _args), do: {:error, ["unknown-arguments"]}

  defp render_result({:ok, value}) do
    IO.puts(Jason.encode!(value, pretty: true))

    if Map.get(value, "complete", true) and Map.get(value, "oracle_exit_status", 0) == 0,
      do: 0,
      else: 1
  end

  defp render_result({:error, errors}) do
    IO.puts(Jason.encode!(%{"complete" => false, "errors" => errors}, pretty: true))
    1
  end

  defp render_result(_), do: render_result({:error, ["oracle-failed"]})

  defp snapshot(root) do
    case tracked_sources(root) do
      {:ok, tracked} ->
        paths = Enum.uniq(tracked ++ [@inventory, ".credo.exs", "mix.lock"]) |> Enum.sort()

        with {:ok, entries} <- snapshot_entries(root, paths) do
          digest =
            :crypto.hash(:sha256, :erlang.term_to_binary(entries)) |> Base.encode16(case: :lower)

          {:ok, %{"complete" => true, "source_digest" => digest, "paths" => paths}}
        end

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp snapshot_entries(root, paths) do
    Enum.reduce_while(paths, {:ok, []}, fn path, {:ok, entries} ->
      case File.read(Path.join(root, path)) do
        {:ok, contents} -> {:cont, {:ok, [{path, :crypto.hash(:sha256, contents)} | entries]}}
        {:error, _reason} -> {:halt, {:error, ["unreadable-source:" <> path]}}
      end
    end)
    |> case do
      {:ok, entries} -> {:ok, Enum.reverse(entries)}
      error -> error
    end
  end

  defp write_inventory(root) do
    with {:ok, tracked} <- tracked_sources(root),
         {:ok, existing} <- read_inventory(root),
         {:ok, maintained, excluded} <- classify(tracked, existing["excluded"] || []),
         :ok <- validate_exclusions(maintained, excluded),
         :ok <-
           write_json(Path.join(root, @inventory), %{
             "schema_version" => 1,
             "maintained" => maintained,
             "excluded" => excluded
           }) do
      {:ok,
       %{
         "complete" => true,
         "maintained_count" => length(maintained),
         "excluded_count" => length(excluded)
       }}
    end
  end

  defp reconcile(root) do
    with {:ok, tracked} <- tracked_sources(root),
         {:ok, inventory} <- read_inventory(root),
         :ok <- validate_inventory(inventory),
         {:ok, maintained, excluded} <- classify(tracked, inventory["excluded"]),
         :ok <- equal_set("maintained-inventory-mismatch", maintained, inventory["maintained"]),
         :ok <- validate_exclusions(maintained, excluded),
         {:ok, _applications} <- Application.ensure_all_started(:credo),
         execution <- File.cd!(root, fn -> Credo.run(["--format", "flycheck"]) end),
         sources <- Credo.Execution.get_source_files(execution),
         effective <-
           sources
           |> Enum.filter(&(&1.status == :valid))
           |> Enum.map(& &1.filename)
           |> Enum.sort(),
         :ok <- assert_complete_execution(execution, sources),
         :ok <- equal_set("effective-input-mismatch", maintained, effective),
         {:ok, digest_data} <- snapshot(root) do
      exit_status = Credo.Execution.get_exit_status(execution)

      evidence = %{
        "complete" => true,
        "maintained" => maintained,
        "effective" => effective,
        "excluded" => excluded,
        "source_digest" => digest_data["source_digest"],
        "oracle_exit_status" => exit_status,
        "errors" => if(exit_status == 0, do: [], else: ["credo-findings-or-error"])
      }

      {:ok, evidence}
    else
      {:error, errors} -> {:error, List.wrap(errors)}
      _ -> {:error, ["oracle-incomplete"]}
    end
  end

  defp tracked_sources(root) do
    case System.cmd("git", ["ls-files", "--cached", "-z"], cd: root, stderr_to_stdout: true) do
      {output, 0} ->
        paths =
          output
          |> String.split(<<0>>, trim: true)
          |> Enum.filter(&elixir_source?/1)
          |> Enum.sort()

        validate_tracked_paths(root, paths)

      {_output, _status} ->
        {:error, ["git-source-enumeration-failed"]}
    end
  end

  defp validate_tracked_paths(root, paths) do
    case Enum.find(paths, &(not safe_path?(&1))) do
      nil -> validate_existing_paths(root, paths)
      path -> {:error, ["unsafe-path:" <> path]}
    end
  end

  defp validate_existing_paths(root, paths) do
    case Enum.find(paths, &(not File.regular?(Path.join(root, &1)))) do
      nil -> {:ok, paths}
      path -> {:error, ["missing-tracked-source:" <> path]}
    end
  end

  defp classify(tracked, excluded) when is_list(excluded) do
    maintained = Enum.filter(tracked, &maintained_scope?/1)
    outside = tracked -- maintained
    exclusion_paths = Enum.map(excluded, &Map.get(&1, "path"))

    cond do
      Enum.any?(outside, &(&1 not in exclusion_paths)) ->
        {:error, Enum.map(outside -- exclusion_paths, &("unclassified-tracked-source:" <> &1))}

      Enum.any?(exclusion_paths, &(&1 not in outside)) ->
        {:error, Enum.map(exclusion_paths -- outside, &("stale-exclusion:" <> to_string(&1)))}

      true ->
        {:ok, maintained, Enum.sort_by(excluded, & &1["path"])}
    end
  end

  defp validate_inventory(%{
         "schema_version" => 1,
         "maintained" => maintained,
         "excluded" => excluded
       })
       when is_list(maintained) and is_list(excluded) do
    cond do
      maintained != Enum.sort(Enum.uniq(maintained)) ->
        {:error, ["maintained-list-not-sorted-unique"]}

      Enum.any?(maintained, &(not safe_path?(&1) or not elixir_source?(&1))) ->
        {:error, ["invalid-maintained-path"]}

      true ->
        validate_exclusions(maintained, excluded)
    end
  end

  defp validate_inventory(_), do: {:error, ["invalid-inventory-schema"]}

  defp validate_exclusions(maintained, excluded) do
    paths = Enum.map(excluded, &Map.get(&1, "path"))

    cond do
      paths != Enum.sort(Enum.uniq(paths)) -> {:error, ["exclusions-not-sorted-unique"]}
      Enum.any?(excluded, &(not valid_exclusion?(&1))) -> {:error, ["invalid-exclusion-record"]}
      Enum.any?(paths, &(&1 in maintained)) -> {:error, ["maintained-source-excluded"]}
      true -> :ok
    end
  end

  defp valid_exclusion?(%{"path" => path, "category" => category, "reason" => reason}) do
    safe_path?(path) and elixir_source?(path) and category in @allowed_categories and
      String.trim(reason) != "" and String.length(String.trim(reason)) >= 20
  end

  defp valid_exclusion?(_), do: false

  defp read_inventory(root) do
    case File.read(Path.join(root, @inventory)) do
      {:ok, contents} ->
        case Jason.decode(contents) do
          {:ok, value} -> {:ok, value}
          _ -> {:error, ["invalid-inventory-json"]}
        end

      {:error, _} ->
        {:error, ["missing-inventory"]}
    end
  end

  defp assert_complete_execution(execution, sources) do
    statuses_valid = Enum.all?(sources, &(&1.status == :valid))
    source_time = Credo.Execution.get_assign(execution, "credo.time.source_files")
    checks_time = Credo.Execution.get_assign(execution, "credo.time.run_checks")

    if not execution.halted and sources != [] and statuses_valid and is_integer(source_time) and
         is_integer(checks_time) do
      :ok
    else
      {:error, ["oracle-incomplete-or-invalid-source"]}
    end
  end

  defp equal_set(label, left, right) do
    left_set = MapSet.new(left)
    right_set = MapSet.new(right)

    if left_set == right_set and length(left) == MapSet.size(left_set) and
         length(right) == MapSet.size(right_set),
       do: :ok,
       else: {:error, [label]}
  end

  defp maintained_scope?(path) do
    Enum.any?(@source_roots, &String.starts_with?(path, &1)) or
      (not String.contains?(path, "/") and elixir_source?(path))
  end

  defp elixir_source?(path), do: String.ends_with?(path, [".ex", ".exs"])

  defp safe_path?(path) when is_binary(path) do
    not String.starts_with?(path, "/") and
      Enum.all?(String.split(path, "/"), &(&1 not in ["", ".", ".."]))
  end

  defp safe_path?(_), do: false

  defp write_json(path, value) do
    temp = path <> ".tmp"

    case File.write(temp, Jason.encode!(value, pretty: true) <> "\n") do
      :ok -> File.rename(temp, path)
      error -> error
    end
  end

  defp safe_error(error), do: error.__struct__ |> Module.split() |> Enum.join(".")
end

System.halt(CredoInventory.main(System.argv()))
