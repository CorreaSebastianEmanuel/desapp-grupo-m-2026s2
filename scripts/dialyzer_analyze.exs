# Native structured boundary: Dialyxir manages PLTs; no textual warning parsing.
[phase, output | sample] = System.argv()

try do
  # Mix prunes tools/inets/IEx when they are not runtime applications.
  otp_paths =
    for app <- ["tools", "inets"],
        path <- Path.wildcard(Path.join([:code.root_dir(), "lib", "#{app}-*", "ebin"])),
        do: path

  true = length(otp_paths) == 2

  iex_path = Path.expand("../iex/ebin", to_string(:code.lib_dir(:elixir)))
  for path <- [iex_path | otp_paths], do: true = Code.prepend_path(path)

  Application.load(:dialyzer)
  Application.load(:dialyxir)
  {:ok, dialyzer_version} = :application.get_key(:dialyzer, :vsn)
  {:ok, dialyxir_version} = :application.get_key(:dialyxir, :vsn)

  true = to_string(dialyzer_version) == "6.0.2"
  true = to_string(dialyxir_version) == "1.4.8"
  true = System.version() == "1.20.3"

  otp =
    File.read!(Path.join([:code.root_dir(), "releases", "29", "OTP_VERSION"])) |> String.trim()

  true = otp == "29.0.6"

  if phase == "prepare" do
    Mix.Task.run("dialyzer", ["--plt"])
    File.write!(output, Jason.encode!(%{status: "prepared"}) <> "\n")
    System.halt(0)
  end

  files =
    case {phase, sample} do
      {"application", []} ->
        Dialyxir.Project.dialyzer_files()

      {"model", []} ->
        {:ok, info} = :dialyzer.plt_info(String.to_charlist(Dialyxir.Project.plt_file()))

        info[:files]
        |> Enum.filter(&String.contains?(to_string(&1), "/_build/#{Mix.env()}/lib/"))
        |> Enum.reject(&String.contains?(to_string(&1), "/football_market/"))

      {"sample", [source]} ->
        destination = Path.join(Path.dirname(output), "beams")
        File.mkdir_p!(destination)
        compiled = Kernel.ParallelCompiler.compile_to_path([source], destination)
        {:ok, modules, _} = compiled
        Enum.map(modules, &String.to_charlist(Path.join(destination, "#{&1}.beam")))
    end

  true = files != []

  warnings =
    :dialyzer.run(
      files: files,
      init_plt: String.to_charlist(Dialyxir.Project.plt_file()),
      check_plt: true,
      warnings: [:unknown]
    )

  findings =
    for {tag, {file, location}, {kind, _arguments}} = warning <- warnings,
        phase != "model" or tag == :warn_unknown or
          kind in [:unknown_function, :unknown_type, :callback_info_missing] do
      relative = file |> to_string() |> Path.relative_to_cwd()

      path =
        if File.regular?(relative) do
          relative
        else
          case Path.wildcard("deps/*/#{relative}") do
            [source] -> source
            _ -> relative
          end
        end

      line = if is_tuple(location), do: elem(location, 0), else: location
      message = warning |> :dialyzer.format_warning() |> to_string()

      %{
        file: path,
        line: line,
        kind: to_string(kind),
        message: message,
        message_sha256: :crypto.hash(:sha256, message) |> Base.encode16(case: :lower),
        source_sha256:
          case File.read(path) do
            {:ok, bytes} -> :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)
            _ -> nil
          end
      }
    end

  report = %{
    status: "analyzed",
    phase: phase,
    profile: to_string(Mix.env()),
    files: length(files),
    versions: %{
      otp: otp,
      elixir: System.version(),
      dialyzer: to_string(dialyzer_version),
      dialyxir: to_string(dialyxir_version)
    },
    findings: findings
  }

  File.write!(output, Jason.encode!(report, pretty: true) <> "\n")
  System.halt(if findings == [], do: 0, else: 2)
rescue
  error ->
    File.write!(
      output,
      Jason.encode!(%{
        status: "error",
        error: "analyzer-execution-or-configuration",
        exception: inspect(error.__struct__)
      }) <> "\n"
    )

    System.halt(1)
catch
  _, _ ->
    File.write!(output, Jason.encode!(%{status: "error", error: "native-analyzer-error"}) <> "\n")
    System.halt(1)
end
