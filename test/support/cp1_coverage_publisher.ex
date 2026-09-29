defmodule FootballMarket.CP1CoveragePublisher do
  @moduledoc false
  @compile {:no_warn_undefined, {:cover, :analyse, 3}}

  # Native Mix owns collection and its own module pages. This small publisher
  # adds the truthful aggregate and stable links for the exact inventory only.
  def publish!(output, inventory_path, metadata) do
    entries = inventory_path |> Code.eval_file() |> elem(0)
    File.mkdir_p!(Path.join(output, "sources"))

    details = Enum.map(entries, &source_detail!/1)
    executed = Enum.sum(Enum.map(details, & &1.executed_lines))
    executable = Enum.sum(Enum.map(details, & &1.executable_lines))

    if executable == 0,
      do: raise(ArgumentError, "CP1 coverage inventory produced no executable lines")

    report = %{
      metadata:
        Map.merge(metadata, %{
          generated_at: DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601(),
          elixir: System.version(),
          otp: :erlang.system_info(:otp_release) |> to_string()
        }),
      threshold: 0,
      executed_lines: executed,
      executable_lines: executable,
      percentage: Float.round(executed * 100 / executable, 2),
      sources: details
    }

    Enum.each(details, &write_source_page!(output, &1))
    File.write!(Path.join(output, "manifest.json"), Jason.encode!(report))
    File.write!(Path.join(output, "report.html"), report_html(report))
    report
  end

  defp source_detail!(%{path: path, module: module} = entry) do
    unless File.regular?(path), do: raise(ArgumentError, "inventory source is missing")

    lines =
      case :cover.analyse(module, :calls, :line) do
        {:ok, calls} -> Enum.map(calls, &normalise_line!/1)
        {:error, _reason} -> raise(ArgumentError, "inventory module has no native coverage data")
      end

    executable = length(lines)
    if executable == 0, do: raise(ArgumentError, "inventory module has no executable lines")

    executed_lines = Enum.count(lines, fn {_line, calls} -> calls > 0 end)

    %{
      path: path,
      module: inspect(module),
      rationale: Map.fetch!(entry, :rationale),
      executable_lines: executable,
      executed_lines: executed_lines,
      unexecuted_lines: executable - executed_lines,
      source_report: "sources/#{safe_name(module)}.html",
      lines: Enum.map(lines, fn {line, calls} -> %{line: line, executed: calls > 0} end)
    }
  end

  defp normalise_line!({{_module, line}, calls}) when is_integer(line) and is_integer(calls),
    do: {line, calls}

  defp normalise_line!({line, calls}) when is_integer(line) and is_integer(calls),
    do: {line, calls}

  defp normalise_line!(_line),
    do: raise(ArgumentError, "native coverage returned malformed line data")

  defp write_source_page!(output, detail) do
    rows =
      Enum.map_join(detail.lines, "", fn %{line: line, executed: executed} ->
        status = if executed, do: "executed", else: "unexecuted"
        "<tr><td>#{line}</td><td>#{status}</td></tr>"
      end)

    page =
      "<html><body><h1>#{escape(detail.path)}</h1><table><tr><th>line</th><th>status</th></tr>#{rows}</table></body></html>"

    File.write!(Path.join(output, detail.source_report), page)
  end

  defp report_html(report) do
    rows =
      Enum.map_join(report.sources, "", fn source ->
        "<tr><td><a href=\"#{escape(source.source_report)}\">#{escape(source.path)}</a></td><td>#{source.executed_lines}</td><td>#{source.unexecuted_lines}</td><td>#{source.executable_lines}</td></tr>"
      end)

    "<html><body><h1>CP1 coverage #{escape(report.metadata.snapshot_label)}</h1><p>#{report.executed_lines}/#{report.executable_lines} executable lines (#{report.percentage}%)</p><table><tr><th>source</th><th>executed</th><th>unexecuted</th><th>total</th></tr>#{rows}</table></body></html>"
  end

  defp safe_name(module), do: module |> inspect() |> String.replace(~r/[^A-Za-z0-9_.-]/, "_")

  defp escape(value),
    do:
      value
      |> to_string()
      |> String.replace("&", "&amp;")
      |> String.replace("<", "&lt;")
      |> String.replace("\"", "&quot;")
end
