#!/usr/bin/env elixir
# Pinned OTP native export reader: each process owns fresh coverage state.
defmodule ApplicationCoverageNative do
  def fail do
    raise ArgumentError, "native-export"
  end

  def run do
    Mix.ensure_application!(:tools)

    {opts, [], []} =
      OptionParser.parse(System.argv(),
        strict: [
          export: :string,
          modules: :string,
          output: :string,
          manifest: :boolean,
          beam_dir: :string,
          inventory: :string
        ]
      )

    if opts[:manifest], do: manifest(opts), else: normalize(opts)
  end

  defp manifest(opts) do
    inventory =
      opts
      |> Keyword.get(:inventory, "config/application_coverage_inventory.json")
      |> File.read!()
      |> Jason.decode!()
      |> Map.fetch!("entries")
      |> Map.new(&{&1["path"], &1})

    fresh_cover()

    beams =
      Path.wildcard(
        Path.join(opts[:beam_dir] || "_build/test/lib/football_market/ebin", "*.beam")
      )

    bindings = beams |> Enum.map(&binding(&1, inventory)) |> Enum.sort_by(& &1["module"])
    if bindings == [], do: fail()
    represented = MapSet.new(bindings, & &1["source_path"])

    missing =
      Enum.filter(inventory, fn {path, row} ->
        row["disposition"] == "include" and not MapSet.member?(represented, path)
      end)

    # A source with no compiled module must not be silently called non-executable.
    if missing != [], do: fail()
    File.write!(Keyword.fetch!(opts, :output), Jason.encode!(bindings) <> "\n")
  end

  defp binding(beam, inventory) do
    {:ok, {module, [compile_info: info]}} =
      :beam_lib.chunks(String.to_charlist(beam), [:compile_info])

    source = info[:source] |> List.to_string() |> Path.relative_to_cwd()
    row = Map.fetch!(inventory, source)
    {:ok, ^module} = :cover.compile_beam(String.to_charlist(beam))
    {lines, markers} = analysed(module, source)

    %{
      "module" => Atom.to_string(module),
      "source_path" => source,
      "source_sha256" => hash(File.read!(source)),
      "beam_sha256" => hash(File.read!(beam)),
      "beam_path" => Path.expand(beam),
      "disposition" => row["disposition"],
      "executable_lines" => Enum.map(lines, & &1["line"]),
      "compiler_markers" => markers
    }
  end

  defp fresh_cover do
    :cover.stop()
    {:ok, _} = :cover.start()
  end

  defp normalize(opts) do
    export = Keyword.fetch!(opts, :export)
    expected = opts |> Keyword.fetch!(:modules) |> File.read!() |> Jason.decode!()
    if not is_list(expected) or expected == [], do: fail()
    Enum.each(expected, &validate_binding/1)
    # OTP import merges repeated records; reject duplicates and truncated framing first.
    raw = File.read!(export)
    records = decode_records(raw, [])
    validate_records(records, expected)
    expected_counters = fresh_counter_identities(expected)
    actual_counters = counter_identities(records)
    if actual_counters != expected_counters, do: fail()
    fresh_cover()
    :ok = :cover.import(String.to_charlist(export))
    names = :cover.imported_modules() |> Enum.map(&Atom.to_string/1) |> Enum.sort()
    if names != Enum.sort(Enum.map(expected, & &1["module"])), do: fail()
    included = Enum.filter(expected, &(&1["disposition"] == "include"))
    lines = Enum.flat_map(included, &partition_lines/1)

    File.write!(
      Keyword.fetch!(opts, :output),
      Jason.encode!(%{
        "schema_version" => 1,
        "export_sha256" => hash(raw),
        "modules" => included,
        "lines" => lines
      }) <> "\n"
    )
  end

  defp validate_binding(binding) do
    # Decode trusted current BEAM debug data to establish all counter atoms
    # before safe native decoding; do not execute application code.
    {:ok, {module, chunks}} =
      :beam_lib.chunks(String.to_charlist(binding["beam_path"]), [:compile_info, :abstract_code])

    source = chunks[:compile_info][:source] |> List.to_string() |> Path.relative_to_cwd()
    if Atom.to_string(module) != binding["module"] or source != binding["source_path"], do: fail()
    if hash(File.read!(source)) != binding["source_sha256"], do: fail()
    if hash(File.read!(binding["beam_path"])) != binding["beam_sha256"], do: fail()
  end

  defp partition_lines(binding) do
    module = String.to_existing_atom(binding["module"])
    {lines, markers} = analysed(module, binding["source_path"])
    if Enum.map(lines, & &1["line"]) != binding["executable_lines"], do: fail()
    if markers != binding["compiler_markers"], do: fail()
    lines
  end

  defp analysed(module, source) do
    {:ok, rows} = :cover.analyse(module, :calls, :line)
    limit = source |> File.read!() |> String.split("\n") |> length()
    Enum.each(rows, &validate_row(&1, module, limit))
    {markers, executable} = Enum.split_with(rows, fn {{_, line}, _} -> line == 0 end)

    lines =
      executable
      |> Enum.map(fn {{_, line}, calls} ->
        %{
          "module" => Atom.to_string(module),
          "source_path" => source,
          "line" => line,
          "calls" => calls
        }
      end)
      |> Enum.sort_by(& &1["line"])

    if length(Enum.uniq_by(lines, & &1["line"])) != length(lines), do: fail()
    {lines, Enum.map(markers, fn {{_, line}, _} -> line end)}
  end

  defp validate_row({{module, line}, calls}, module, limit)
       when is_integer(line) and line >= 0 and line <= limit and is_integer(calls) and calls >= 0,
       do: :ok

  defp validate_row(_, _, _), do: fail()

  defp decode_records(<<>>, acc), do: Enum.reverse(acc)

  defp decode_records(<<size, data::binary>>, acc) when size > 0 do
    <<encoded::binary-size(^size), rest::binary>> = data
    term = :erlang.binary_to_term(encoded, [:safe])
    {record, remaining} = expanded_record(term, rest)
    decode_records(remaining, [record | acc])
  end

  defp decode_records(_, _), do: fail()

  defp expanded_record({:"$size", size}, rest) when is_integer(size) and size > 255 do
    <<encoded::binary-size(^size), remaining::binary>> = rest
    {:erlang.binary_to_term(encoded, [:safe]), remaining}
  end

  defp expanded_record(term, rest), do: {term, rest}

  defp validate_records(records, expected) do
    {files, counters} = Enum.split_with(records, &match?({:file, _, _}, &1))
    names = Enum.map(files, fn {:file, module, _} -> Atom.to_string(module) end)
    if Enum.sort(names) != Enum.sort(Enum.map(expected, & &1["module"])), do: fail()
    Enum.each(files, &validate_file(&1, expected))
    Enum.each(counters, &validate_counter(&1, names))
    keys = Enum.map(counters, &elem(&1, 0))
    if length(Enum.uniq(keys)) != length(keys), do: fail()
  end

  defp fresh_counter_identities(expected) do
    fresh_cover()

    Enum.each(expected, fn binding ->
      {:ok, _module} = :cover.compile_beam(String.to_charlist(binding["beam_path"]))
    end)

    path =
      Path.join(
        System.tmp_dir!(),
        "application-coverage-baseline-#{System.unique_integer([:positive])}.coverdata"
      )

    try do
      :ok = :cover.export(String.to_charlist(path))
      path |> File.read!() |> decode_records([]) |> counter_identities()
    after
      File.rm(path)
    end
  end

  defp counter_identities(records) do
    records
    |> Enum.filter(&match?({{:bump, _, _, _, _, _}, _}, &1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  defp validate_file({:file, module, beam}, expected) do
    binding = Enum.find(expected, &(&1["module"] == Atom.to_string(module)))
    if Path.expand(List.to_string(beam)) != binding["beam_path"], do: fail()
  end

  defp validate_counter({{:bump, module, function, arity, clause, line}, calls}, names)
       when is_atom(module) and is_atom(function) do
    if Atom.to_string(module) not in names, do: fail()
    if not Enum.all?([arity, clause, line, calls], &nonnegative_integer?/1), do: fail()
  end

  defp validate_counter(_, _), do: fail()
  defp nonnegative_integer?(value), do: is_integer(value) and value >= 0

  defp hash(value), do: :crypto.hash(:sha256, value) |> Base.encode16(case: :lower)
end

try do
  ApplicationCoverageNative.run()
rescue
  _ ->
    IO.puts(:stderr, "APPLICATION_COVERAGE_NATIVE status=failed category=native-export")
    System.halt(1)
catch
  _, _ ->
    IO.puts(:stderr, "APPLICATION_COVERAGE_NATIVE status=failed category=native-export")
    System.halt(1)
end
