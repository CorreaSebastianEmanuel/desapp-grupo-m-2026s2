defmodule FootballMarket.Observability.ContextTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Observability.Context

  setup do
    previous = Logger.metadata()
    on_exit(fn -> Logger.reset_metadata(previous) end)
    :ok
  end

  test "scoped context restores all caller metadata on return raise and throw" do
    Logger.reset_metadata(
      correlation_id: "outer",
      request_id: "http",
      secret: "private",
      attempt: 2
    )

    original = Logger.metadata()

    assert Context.with_context([correlation_id: "inner"], fn ->
             assert Logger.metadata()[:request_id] == nil
             assert Logger.metadata()[:attempt] == nil
             :returned
           end) == :returned

    assert Logger.metadata() == original
    assert_raise RuntimeError, fn -> Context.with_context([], fn -> raise "fixture" end) end
    assert catch_throw(Context.with_context([], fn -> throw(:fixture) end)) == :fixture
    assert Logger.metadata() == original
  end

  test "invalid origins use a valid fallback without modifying caller context" do
    for bad <- [nil, "", <<255>>, "bad" <> <<0>>, String.duplicate("a", 201), %{}] do
      assert Context.id(bad, "fallback") == "fallback"
      assert {:ok, _} = Ecto.UUID.cast(Context.id(bad))
    end

    assert Context.id("é", "fallback") == "é"
    assert Context.id("caller\nvalue") == "caller\nvalue"
  end

  test "provider coordinator and worker receive only approved caller context" do
    Logger.reset_metadata(
      correlation_id: "provider-origin",
      request_id: "http",
      secret: "private"
    )

    runtime = FootballMarket.Providers.Runtime
    deadline = runtime.now_us(nil) + 1_000_000
    handle = runtime.launch(fn -> Logger.metadata() end, deadline, nil)

    try do
      assert {:ready, metadata, _} = runtime.await(handle, deadline, nil)
      assert metadata[:correlation_id] == "provider-origin"
      assert metadata[:request_id] == "http"
      refute Keyword.has_key?(metadata, :secret)
    after
      runtime.close(handle, nil)
    end

    assert Logger.metadata()[:secret] == "private"
  end
end
