defmodule FootballMarket.ApplicationCoverageNativeTest do
  use ExUnit.Case, async: false
  @moduletag :unit

  @script Path.expand("../../scripts/application_coverage_native.exs", __DIR__)

  test "native reader rejects missing, truncated, or foreign exports without output" do
    directory =
      Path.join(System.tmp_dir!(), "app-coverage-native-#{System.unique_integer([:positive])}")

    File.mkdir_p!(directory)
    on_exit(fn -> File.rm_rf!(directory) end)

    modules = Path.join(directory, "modules.json")
    output = Path.join(directory, "normalized.json")
    File.write!(modules, "[]\n")

    isolated = [
      {"APPLICATION_COVERAGE_DIR", nil},
      {"APPLICATION_COVERAGE_RUN_ID", nil},
      {"APPLICATION_COVERAGE_SNAPSHOT", nil},
      {"CP1_PROFILE_COVERAGE", nil}
    ]

    missing =
      System.cmd(
        "mix",
        [
          "run",
          "--no-start",
          @script,
          "--export",
          Path.join(directory, "missing.coverdata"),
          "--modules",
          modules,
          "--output",
          output
        ],
        env: isolated,
        stderr_to_stdout: true
      )

    assert elem(missing, 1) != 0
    refute File.exists?(output)

    malformed_export = Path.join(directory, "truncated.coverdata")
    File.write!(malformed_export, "not native coverage data")

    malformed =
      System.cmd(
        "mix",
        [
          "run",
          "--no-start",
          @script,
          "--export",
          malformed_export,
          "--modules",
          modules,
          "--output",
          output
        ],
        env: isolated,
        stderr_to_stdout: true
      )

    assert elem(malformed, 1) != 0
    refute File.exists?(output)
  end

  test "collector inventory records explicit first-party scope and excludes tests and support" do
    inventory =
      Path.expand("../../config/application_coverage_inventory.json", __DIR__)
      |> File.read!()
      |> Jason.decode!()

    entries = inventory["entries"]
    assert inventory["schema_version"] == 1

    assert Enum.any?(
             entries,
             &(&1["path"] == "lib/football_market.ex" and &1["disposition"] == "include")
           )

    assert Enum.any?(
             entries,
             &(&1["path"] == "test/ci/application_coverage_native_test.exs" and
                 &1["role"] == "test" and &1["disposition"] == "exclude")
           )

    assert Enum.any?(
             entries,
             &(&1["path"] == "test/support/test_profile_audit.ex" and
                 &1["role"] == "test-support" and &1["disposition"] == "exclude")
           )
  end

  test "native fixture preserves covered and never-called lines and rejects lost modules" do
    directory = Path.expand("tmp/application-native-#{System.unique_integer([:positive])}")
    File.mkdir_p!(directory)
    on_exit(fn -> File.rm_rf!(directory) end)
    source = Path.join(directory, "fixture.ex")
    beams = Path.join(directory, "beams")
    File.mkdir_p!(beams)

    File.write!(
      source,
      "defmodule CoverageFixture do\n  def hit, do: :ok\n  def missed, do: :missing\n  def pick(:hit), do: :hit; def pick(:miss), do: :miss\n  defmodule Nested do\n    def missed, do: :nested\n  end\nend\ndefmodule CoverageFixture.Empty do\nend\n"
    )

    export = Path.join(directory, "fixture.coverdata")
    empty_export = Path.join(directory, "empty.coverdata")
    inventory = Path.join(directory, "inventory.json")
    manifest = Path.join(directory, "modules.json")
    output = Path.join(directory, "normalized.json")

    File.write!(
      inventory,
      Jason.encode!(%{
        "entries" => [%{"path" => Path.relative_to_cwd(source), "disposition" => "include"}]
      })
    )

    setup = """
    Mix.ensure_application!(:tools)
    for {module, bytes} <- Code.compile_file(System.fetch_env!("FIXTURE_SOURCE")) do
      File.write!(Path.join(System.fetch_env!("FIXTURE_BEAMS"), Atom.to_string(module) <> ".beam"), bytes)
    end
    {:ok, _} = :cover.start()
    for beam <- Path.wildcard(Path.join(System.fetch_env!("FIXTURE_BEAMS"), "*.beam")) do
      {:ok, _} = :cover.compile_beam(String.to_charlist(beam))
    end
    :ok = CoverageFixture.hit()
    :hit = CoverageFixture.pick(:hit)
    :miss = CoverageFixture.pick(:miss)
    :ok = :cover.export(String.to_charlist(System.fetch_env!("FIXTURE_EXPORT")))
    :ok = :cover.reset()
    :ok = :cover.export(String.to_charlist(System.fetch_env!("FIXTURE_EMPTY_EXPORT")))
    """

    env = [
      {"APPLICATION_COVERAGE_DIR", nil},
      {"APPLICATION_COVERAGE_RUN_ID", nil},
      {"APPLICATION_COVERAGE_SNAPSHOT", nil},
      {"CP1_PROFILE_COVERAGE", nil},
      {"CP1_COVERAGE_OUTPUT", nil},
      {"FIXTURE_SOURCE", source},
      {"FIXTURE_BEAMS", beams},
      {"FIXTURE_EXPORT", export},
      {"FIXTURE_EMPTY_EXPORT", empty_export}
    ]

    {_, 0} =
      System.cmd("mix", ["run", "--no-start", "-e", setup], env: env, stderr_to_stdout: true)

    {_, 0} =
      System.cmd(
        "mix",
        [
          "run",
          "--no-start",
          @script,
          "--manifest",
          "--beam-dir",
          beams,
          "--inventory",
          inventory,
          "--output",
          manifest
        ],
        env: env,
        stderr_to_stdout: true
      )

    args = [
      "run",
      "--no-start",
      @script,
      "--export",
      export,
      "--modules",
      manifest,
      "--output",
      output
    ]

    {_, 0} = System.cmd("mix", args, env: env, stderr_to_stdout: true)
    report = output |> File.read!() |> Jason.decode!()
    assert Enum.any?(report["lines"], &(&1["line"] == 2 and &1["calls"] > 0))
    assert Enum.any?(report["lines"], &(&1["line"] == 3 and &1["calls"] == 0))
    assert Enum.any?(report["lines"], &(&1["line"] == 6 and &1["calls"] == 0))
    refute Enum.any?(report["lines"], &(&1["line"] == 0))
    bindings = manifest |> File.read!() |> Jason.decode!()
    empty = Enum.find(bindings, &(&1["module"] == "Elixir.CoverageFixture.Empty"))
    assert empty["executable_lines"] == []

    # Each batch import owns fresh :cover state, including the zero-call export
    # between two executed exports. Reusing baseline identities cannot merge calls.
    copied_export = Path.join(directory, "copied.coverdata")
    File.cp!(export, copied_export)
    jobs_path = Path.join(directory, "batch.json")

    jobs =
      [export, empty_export, copied_export]
      |> Enum.with_index()
      |> Enum.map(fn {input, index} ->
        %{"export" => input, "output" => Path.join(directory, "batch-#{index}.json")}
      end)

    File.write!(jobs_path, Jason.encode!(jobs))
    batch_args = ["run", "--no-start", @script, "--batch", jobs_path, "--modules", manifest]
    {_, 0} = System.cmd("mix", batch_args, env: env, stderr_to_stdout: true)
    batch_reports = Enum.map(jobs, &(&1["output"] |> File.read!() |> Jason.decode!()))
    assert Enum.at(batch_reports, 0) == report
    assert Enum.at(batch_reports, 2) == report
    assert Enum.all?(Enum.at(batch_reports, 1)["lines"], &(&1["calls"] == 0))

    for invalid <- [[], [hd(jobs), hd(jobs)], [Map.put(hd(jobs), "output", export)]] do
      File.write!(jobs_path, Jason.encode!(invalid))
      {_, status} = System.cmd("mix", batch_args, env: env, stderr_to_stdout: true)
      assert status != 0
      assert File.read!(export) == File.read!(copied_export)
    end

    original_empty = File.read!(empty_export)
    empty_records = decode_native_export(original_empty)
    counter = Enum.find(empty_records, &match?({{:bump, _, _, _, _, _}, _}, &1))
    assert counter
    File.write!(jobs_path, Jason.encode!(jobs))

    for invalid <- [
          encode_native_export(List.delete(empty_records, counter)),
          original_empty <> original_empty,
          "truncated"
        ] do
      Enum.each(jobs, &File.rm(&1["output"]))
      File.write!(empty_export, invalid)
      {_, status} = System.cmd("mix", batch_args, env: env, stderr_to_stdout: true)
      assert status != 0
      refute File.exists?(Enum.at(jobs, 1)["output"])
    end

    File.write!(empty_export, original_empty)
    original_manifest = File.read!(manifest)
    [first | _] = Jason.decode!(original_manifest)
    File.write!(manifest, Jason.encode!([first]))
    File.rm!(output)
    {_, status} = System.cmd("mix", args, env: env, stderr_to_stdout: true)
    assert status != 0
    refute File.exists?(output)
    File.write!(manifest, original_manifest)
    original_export = File.read!(export)

    counters = decode_native_export(original_export)

    executed =
      Enum.find(counters, fn
        {{:bump, module, :pick, 1, _clause, line}, calls} ->
          module == CoverageFixture and line == 4 and calls > 0

        _ ->
          false
      end)

    assert executed
    {{:bump, module, :pick, 1, _clause, line}, _calls} = executed

    assert Enum.any?(counters, fn
             {{:bump, ^module, :pick, 1, _other_clause, ^line}, calls} -> calls > 0
             _ -> false
           end)

    incomplete = List.delete(counters, executed)
    File.write!(export, encode_native_export(incomplete))
    File.rm(output)
    {_, incomplete_status} = System.cmd("mix", args, env: env, stderr_to_stdout: true)
    assert incomplete_status != 0
    refute File.exists?(output)

    File.write!(export, original_export)
    File.write!(export, original_export <> original_export)
    {_, duplicate_status} = System.cmd("mix", args, env: env, stderr_to_stdout: true)
    assert duplicate_status != 0
    refute File.exists?(output)
  end

  defp decode_native_export(binary), do: decode_native_export(binary, [])

  defp decode_native_export(<<>>, acc), do: Enum.reverse(acc)

  defp decode_native_export(<<size, data::binary>>, acc) when size > 0 do
    <<encoded::binary-size(^size), rest::binary>> = data
    term = :erlang.binary_to_term(encoded)

    case term do
      {:"$size", expanded} when is_integer(expanded) and expanded > 255 ->
        <<large::binary-size(^expanded), remaining::binary>> = rest
        decode_native_export(remaining, [:erlang.binary_to_term(large) | acc])

      _ ->
        decode_native_export(rest, [term | acc])
    end
  end

  defp encode_native_export(records) do
    Enum.map_join(records, fn record ->
      encoded = :erlang.term_to_binary(record)

      if byte_size(encoded) <= 255 do
        <<byte_size(encoded), encoded::binary>>
      else
        header = :erlang.term_to_binary({:"$size", byte_size(encoded)})
        <<byte_size(header), header::binary, encoded::binary>>
      end
    end)
  end
end
