defmodule FootballMarket.Providers.FootballData.TransportRuntimeTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  import ExUnit.CaptureLog
  alias FootballMarket.Providers
  alias Providers.{Runtime, FootballData}
  alias FootballData.{MintTransport, TLSServer, Configuration, ContractCase, FixtureData}
  @token "FD_SYNTHETIC_SENTINEL"
  defp server(options \\ []) do
    s = TLSServer.start(options)
    on_exit(fn -> TLSServer.stop(s) end)
    s
  end

  defp context(timeout \\ 2000),
    do: %{
      deadline_us: System.monotonic_time(:microsecond) + timeout * 1000,
      runtime: {Runtime, nil}
    }

  defp options(s),
    do: [
      provider:
        {FootballData,
         Configuration.new(%{
           enabled: true,
           token: @token,
           transport: {MintTransport, s.transport}
         })},
      positions: ContractCase.positions()
    ]

  defp request(timeout \\ 2000),
    do: %{league_code: "PL", start_year: 2026, end_year: 2027, timeout_ms: timeout}

  defp responder(path) do
    b = FixtureData.base()

    body =
      case path do
        "/v4/competitions/PL" -> b.discovery
        "/v4/competitions/PL/teams?season=2026" -> b.teams
        "/v4/teams/10" -> b.team
        "/v4/persons/" <> id -> Map.put(b.person, "id", String.to_integer(id))
      end

    {200, [], Jason.encode!(body)}
  end

  test "real facade verifies all fixed route requests and complete independent facts/bindings" do
    s = server(responder: &responder/1)
    assert {:ok, result} = Providers.catalog(request(), options(s))
    ContractCase.assert_facts(result, %{})
    assert result.provenance.fixture_id == nil
    assert DateTime.diff(DateTime.utc_now(), result.provenance.retrieved_at) in 0..2

    expected = [
      "/v4/competitions/PL",
      "/v4/competitions/PL/teams?season=2026",
      "/v4/teams/10",
      "/v4/persons/100",
      "/v4/persons/101",
      "/v4/persons/102",
      "/v4/persons/103",
      "/v4/competitions/PL"
    ]

    for path <- expected do
      assert_receive {:tls_request, "GET", ^path, headers}, 1000
      assert headers["x-auth-token"] == @token
      assert headers["host"] == "localhost:#{s.transport.port}"
      assert_receive {:tls_closed, _}, 1000
    end

    refute_receive {:tls_request, _, _, _}, 20
  end

  for {status, category} <- [
        {401, :authentication_failed},
        {403, :authentication_failed},
        {404, :not_found},
        {410, :not_found},
        {429, :rate_limited},
        {500, :unavailable},
        {400, :invalid_response}
      ] do
    @status status
    @category category
    test "observed #{@status} retains its category without reading a blocked hostile body" do
      s = server(status: @status, body: @token, block_body: true, headers: [{"Retry-After", "2"}])
      assert {:error, e} = Providers.catalog(request(), options(s))
      assert e.category == @category

      if @status == 429,
        do: assert(e.retry_after_ms in 1900..2000),
        else: assert(e.retry_after_ms == nil)

      refute inspect(e) =~ @token
      assert_receive {:tls_closed, _}, 1000
    end
  end

  for location <- ["same-origin", "cross-origin"] do
    @location location
    test "redirect #{@location} is never followed and emits no secret diagnostics" do
      target = server()

      s =
        server(
          status: 302,
          headers: fn port ->
            [
              {"Location",
               "https://localhost:#{if @location == "same-origin", do: port, else: target.transport.port}/FD_SYNTHETIC_SENTINEL"}
            ]
          end,
          body: @token
        )

      log =
        capture_log(fn ->
          assert {:error, e} = Providers.catalog(request(), options(s))
          assert e.category == :unavailable
          refute inspect(e) =~ @token
        end)

      refute log =~ @token
      assert_receive {:tls_request, "GET", "/v4/competitions/PL", _}, 1000
      assert_receive {:tls_closed, _}, 1000
      refute_receive {:tls_request, _, _, _}, 50
    end
  end

  test "unavailable listener and TLS hostname/CA mismatch fail before token delivery" do
    s = server(certificate_hostname: "wrong.local")

    assert {:error, :unavailable} =
             MintTransport.request({:discovery, "PL"}, @token, context(), s.transport)

    refute_receive {:tls_request, _, _, _}, 30
    correct = server()

    assert {:error, :unavailable} =
             MintTransport.request({:discovery, "PL"}, @token, context(), %{
               correct.transport
               | cacertfile: s.transport.cacertfile
             })

    refute_receive {:tls_request, _, _, _}, 30
    {:ok, listener} = :gen_tcp.listen(0, [:binary, ip: {127, 0, 0, 1}])
    {:ok, {_, port}} = :inet.sockname(listener)
    :gen_tcp.close(listener)

    assert {:error, :unavailable} =
             MintTransport.request({:discovery, "PL"}, @token, context(100), %{
               correct.transport
               | port: port
             })
  end

  for mode <- [:block_headers, :block_body, :handshake_block] do
    @mode mode
    test "#{@mode} deadline and caller exit close the owned socket at the peer" do
      s = server([{@mode, true}])
      assert {:error, error} = Providers.catalog(request(150), options(s))
      assert error.category == :timeout
      assert_receive {:tls_closed, _}, 1000
      refute_receive {:tls_not_closed, _}, 20
      # Drain the earlier request event before the separate caller-exit case.
      receive do
        {:tls_request, _, _, _} -> :ok
        {:tls_accepted, _} -> :ok
      after
        0 -> :ok
      end

      {caller, monitor} = spawn_monitor(fn -> Providers.catalog(request(2000), options(s)) end)

      if @mode == :handshake_block,
        do: assert_receive({:tls_accepted, _}, 1000),
        else: assert_receive({:tls_request, _, _, _}, 1000)

      Process.exit(caller, :kill)
      assert_receive {:DOWN, ^monitor, :process, ^caller, :killed}, 1000
      assert_receive {:tls_closed, _}, 1000
      refute_receive {:tls_not_closed, _}, 20
      refute_receive {:provider_ready, _, _, _}, 20
      refute_receive {:tls_request, _, _, _}, 20
    end
  end

  test "malformed and truncated 200 bodies never become empty success" do
    for opts <- [[body: "{"], [body: "{}", truncated: true]] do
      s = server(opts)
      assert {:error, error} = Providers.catalog(request(500), options(s))
      assert error.category == :invalid_response
    end
  end

  test "split status/header packets retain a valid quota delay without reading the body" do
    s = server(status: 429, split_status: true, block_body: true, headers: [{"Retry-After", "2"}])
    assert {:error, error} = Providers.catalog(request(), options(s))
    assert error.category == :rate_limited
    assert error.retry_after_ms in 1900..2000
    assert_receive {:tls_closed, _}, 1000
  end

  def now_us(%{owner: _} = state), do: Runtime.now_us(state)

  def now_us(_) do
    [value | rest] = Process.get(:fd_port_times)
    Process.put(:fd_port_times, rest)
    value
  end

  test "connect consumes the absolute budget; no HTTP write starts afterward" do
    s = server()
    Process.put(:fd_port_times, [0, 2_000_000])

    assert {:error, :timeout} =
             MintTransport.request(
               {:discovery, "PL"},
               @token,
               %{deadline_us: 2_000_000, runtime: {__MODULE__, nil}},
               s.transport
             )

    assert_receive {:tls_closed, _}, 1000
    refute_receive {:tls_request, _, _, _}, 30
  end

  test "huge valid budgets work with actual TLS rather than overflowing VM waits" do
    for timeout <- [4_294_968_000, 10_000_000_000_000] do
      s = server(responder: &responder/1)
      assert {:ok, result} = Providers.catalog(request(timeout), options(s))
      ContractCase.assert_facts(result, %{})
      for _ <- 1..8, do: assert_receive({:tls_closed, _}, 1000)
    end
  end

  test "protocol failure after observed status preserves its category and closes at the peer" do
    for {status, category} <- [
          {403, :authentication_failed},
          {429, :rate_limited},
          {200, :invalid_response}
        ] do
      s = server(raw_response: "HTTP/1.1 #{status} Fixture\r\ninvalid header\r\n\r\n")
      assert {:error, error} = Providers.catalog(request(), options(s))
      assert error.category == category
      assert error.retry_after_ms == nil
      assert_receive {:tls_closed, _}, 1000
    end
  end

  defdelegate launch(f, d, s), to: Runtime
  defdelegate cancel(h, s), to: Runtime
  defdelegate close(h, s), to: Runtime

  def await(h, d, s) do
    result = Runtime.await(h, d, s)

    case result do
      {:ready, _, ready} -> send(s.owner, {:expiry_ready, ready})
      _ -> :ok
    end

    result
  end

  def utc_now(s) do
    call = Process.get(:expiry_utc_calls, 0) + 1
    Process.put(:expiry_utc_calls, call)
    utc = DateTime.utc_now()
    if call == 1, do: send(s.owner, {:expiry_receipt, System.monotonic_time(:microsecond), utc})
    Process.sleep(if(call == 1, do: s.parse_ms, else: s.post_ms))
    utc
  end

  for format <- [:delta, :date, :reset],
      {seconds, parse_ms, post_ms} <- [
        {3, 400, 0},
        {3, 0, 400},
        {3, 200, 200},
        {1, 1200, 0},
        {1, 0, 1200},
        {1, 600, 600}
      ] do
    @format format
    @seconds seconds
    @parse_ms parse_ms
    @post_ms post_ms
    test "source anchored HTTPS #{@format} #{@seconds}s with #{@parse_ms}/#{@post_ms}ms processing" do
      owner = self()

      responder = fn _ ->
        date = DateTime.utc_now() |> DateTime.add(@seconds, :second) |> DateTime.to_unix()
        {{y, m, d}, {h, min, sec}} = :calendar.system_time_to_universal_time(date, :second)

        header =
          case @format do
            :delta ->
              {"Retry-After", Integer.to_string(@seconds)}

            :reset ->
              {"X-RequestCounter-Reset", Integer.to_string(@seconds)}

            :date ->
              {"Retry-After",
               :httpd_util.rfc1123_date({{y, m, d}, {h, min, sec}}) |> List.to_string()}
          end

        send(owner, {:expiry_header, header})
        {429, [header], "ignored"}
      end

      s = server(responder: responder)

      opts =
        Keyword.put(
          options(s),
          :runtime,
          {__MODULE__, %{owner: owner, parse_ms: @parse_ms, post_ms: @post_ms}}
        )

      assert {:error, error} = Providers.catalog(request(5000), opts)
      assert error.category == :rate_limited
      assert_receive {:tls_request, "GET", "/v4/competitions/PL", headers}, 1000
      assert headers["x-auth-token"] == @token
      assert_receive {:tls_closed, _}, 1000
      assert_receive {:expiry_receipt, received, utc}, 1000
      assert_receive {:expiry_ready, ready}, 1000
      assert_receive {:expiry_header, {_, value}}, 1000

      wait_us =
        if @format == :date do
          instant = :httpd_util.convert_request_date(String.to_charlist(value))

          :calendar.datetime_to_gregorian_seconds(instant) * 1_000_000 -
            (:calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}}) * 1_000_000 +
               DateTime.to_unix(utc, :microsecond))
        else
          @seconds * 1_000_000
        end

      remaining = div(max(received + wait_us - ready, 0), 1000)

      if @seconds == 1 do
        assert error.retry_after_ms == nil
      else
        assert is_integer(error.retry_after_ms) and error.retry_after_ms > 0
        assert error.retry_after_ms in max(remaining - 100, 1)..(remaining + 50)
      end

      refute inspect(error) =~ @token
      refute_receive {:tls_request, _, _, _}, 20
    end
  end
end
