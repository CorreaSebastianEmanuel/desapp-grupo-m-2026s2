defmodule FootballMarket.TestProfileFormatter do
  @moduledoc false
  use GenServer

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  def init(_),
    do: {:ok, {System.fetch_env!("PROFILE_EVENTS"), System.fetch_env!("PROFILE_NONCE")}}

  def handle_cast({event, test}, {path, nonce} = identity)
      when event in [:test_started, :test_finished] do
    state =
      case {event, test.state} do
        {:test_started, _} -> "started"
        {:test_finished, nil} -> "passed"
        {:test_finished, {:excluded, _}} -> "excluded"
        {:test_finished, {:skipped, _}} -> "skipped"
        _ -> "failed"
      end

    if state != "excluded" do
      File.write!(
        path,
        Jason.encode!(%{
          nonce: nonce,
          runner: "exunit",
          file: Path.relative_to_cwd(test.tags.file),
          case_id: inspect(test.module) <> ":" <> Atom.to_string(test.name),
          state: state,
          failure_line: failure_line(test.state)
        }) <> "\n",
        [:append]
      )
    end

    {:noreply, identity}
  end

  def handle_cast(_, path), do: {:noreply, path}

  defp failure_line({:failed, [{_, _, stack} | _]}) do
    Enum.find_value(stack, 0, fn
      {_, _, _, options} ->
        if String.contains?(to_string(options[:file] || ""), "test/"), do: options[:line]

      _ ->
        nil
    end)
  end

  defp failure_line(_), do: 0
end
