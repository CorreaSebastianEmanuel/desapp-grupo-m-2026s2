defmodule FootballMarket.Observability.JSONFormatterTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Observability.JSONFormatter

  defp render(message, meta \\ %{}, level \\ :info) do
    {module, config} = Logger.Formatter.new(JSONFormatter.options())

    module.format(%{level: level, msg: message, meta: Map.put(meta, :time, 0)}, config)
    |> IO.iodata_to_binary()
  end

  test "runtime format is one UTC JSON line with typed allowlisted fields" do
    line =
      render({:string, "request"}, %{
        event: "http.request.stop",
        status: 200,
        duration_ms: 7,
        correlation_id: "trace",
        secret: "private",
        args: %{token: "private"}
      })

    assert String.ends_with?(line, "\n")
    assert length(String.split(line, "\n", trim: true)) == 1

    assert Jason.decode!(line) == %{
             "timestamp" => "1970-01-01T00:00:00.000Z",
             "level" => "info",
             "message" => "request",
             "event" => "http.request.stop",
             "status" => 200,
             "duration_ms" => 7,
             "correlation_id" => "trace"
           }

    refute line =~ "private"
    refute line =~ <<27>>
  end

  test "quotes newlines Unicode and malformed bytes cannot break framing" do
    line = render({:string, ["hello\n\"世界\"", <<255>>]}, %{request_id: <<255>>})
    assert length(String.split(line, "\n", trim: true)) == 1
    assert Jason.decode!(line)["message"] == "hello\n\"世界\"�"
    assert Jason.decode!(line)["request_id"] == "�"
  end

  test "standard reports and truncated messages remain valid JSON" do
    assert is_binary(
             render({:report, %{status: :ready}})
             |> Jason.decode!()
             |> Map.fetch!("message")
           )

    line = render({:string, String.duplicate("é", 9000)}, %{}, :warning)
    result = Jason.decode!(line)
    assert result["level"] == "warning"
    assert result["message"] =~ "(truncated)"
    assert String.valid?(result["message"])
    assert byte_size(result["message"]) < 8300
  end
end
