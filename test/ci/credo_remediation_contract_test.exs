defmodule FootballMarket.CredoRemediationContractTest do
  use ExUnit.Case, async: false
  @moduletag :unit

  test "analyzer is exactly pinned and never loaded at runtime" do
    assert {:credo, "1.7.19", options} =
             Enum.find(FootballMarket.MixProject.project()[:deps], &(elem(&1, 0) == :credo))

    assert options[:only] == [:dev, :test]
    assert options[:runtime] == false
    {lock, _} = Code.eval_file("mix.lock")
    assert elem(lock[:credo], 2) == "1.7.19"
    assert apply(Credo, :version, []) == "1.7.19"
  end

  test "standard invocation documents default priority without suppression" do
    readme = File.read!("README.md")
    assert readme =~ "MIX_ENV=test mix credo --format flycheck"
    assert readme =~ "1.7.19"
    assert readme =~ "default-priority"
    assert source_policy?(inventory())
  end

  test "effective named configuration covers every maintained source with stock checks" do
    assert valid_config?(".credo.exs", inventory())
  end

  test "contract rejects omitted inputs, hidden exclusions and modified rules" do
    directory =
      Path.join(System.tmp_dir!(), "credo-contract-#{System.unique_integer([:positive])}")

    File.mkdir_p!(directory)
    on_exit(fn -> File.rm_rf!(directory) end)
    paths = ["test/maintained.exs", "priv/repo/migrations/example.exs", "mix.exs"]

    Enum.each(paths, fn path ->
      full = Path.join(directory, path)
      File.mkdir_p!(Path.dirname(full))
      File.write!(full, "# maintained source\n")
    end)

    inputs = Enum.map(paths, &Path.join(directory, &1))

    config = %{
      name: "default",
      files: %{included: inputs, excluded: []},
      strict: false,
      color: false
    }

    path = Path.join(directory, ".credo.exs")
    write_config(path, config)
    assert valid_config?(path, inputs)

    Enum.each(inputs, fn omitted ->
      write_config(path, put_in(config, [:files, :included], inputs -- [omitted]))
      refute valid_config?(path, inputs)
    end)

    write_config(path, put_in(config, [:files, :excluded], [hd(inputs)]))
    refute valid_config?(path, inputs)

    Enum.each(
      [
        %{disabled: [{Credo.Check.Readability.ModuleDoc, []}]},
        %{enabled: [{Credo.Check.Readability.MaxLineLength, [max_length: 999]}]}
      ],
      fn checks ->
        write_config(path, Map.put(config, :checks, checks))
        refute valid_config?(path, inputs)
      end
    )

    File.write!(
      hd(inputs),
      "#" <> " credo:" <> "disable-for-this-file Credo.Check.Readability.ModuleDoc\n"
    )

    refute source_policy?(inputs)
  end

  defp write_config(path, config),
    do: File.write!(path, inspect(%{configs: [config]}, limit: :infinity))

  defp inventory do
    {output, 0} =
      System.cmd("git", ["ls-files", "--cached", "--others", "--exclude-standard", "-z"])

    output
    |> String.split("\0", trim: true)
    |> Enum.uniq()
    |> Enum.filter(fn path ->
      (String.starts_with?(path, ["lib/", "test/", "priv/", "config/", "scripts/"]) or
         Path.dirname(path) == ".") and Path.extname(path) in [".ex", ".exs"] and
        File.regular?(path)
    end)
    |> Enum.map(&Path.expand/1)
  end

  defp source_policy?(inputs) do
    Enum.all?(inputs, fn path ->
      # Construct the marker so this policy test does not suppress its own findings.
      marker = "#" <> " credo:" <> "disable"
      not String.contains?(File.read!(path), marker)
    end)
  end

  defp normalized_checks(checks), do: Enum.sort(checks.enabled)

  defp valid_config?(path, inputs) do
    if File.regular?(path) do
      {:ok, _} = Application.ensure_all_started(:credo)
      exec = apply(Credo.Execution, :build, [[]])
      exec = apply(Credo.Execution.Task.AppendDefaultConfig, :call, [exec, []])
      {:ok, stock} = apply(Credo.ConfigFile, :read_or_default, [exec, System.tmp_dir!()])

      {:ok, effective} =
        apply(Credo.ConfigFile, :read_from_file_path, [exec, File.cwd!(), Path.expand(path)])

      files =
        apply(Credo.Sources, :find, [
          Map.merge(exec, %{files: effective.files, cli_options: %{path: File.cwd!()}})
        ])

      found = MapSet.new(files, &Path.expand(&1.filename))

      Enum.all?(inputs, &MapSet.member?(found, Path.expand(&1))) and
        normalized_checks(effective.checks) == normalized_checks(stock.checks) and
        not effective.strict and source_policy?(inputs)
    else
      false
    end
  end
end
