defmodule FootballMarket.Providers.FootballData.TLSServer do
  @moduledoc false
  def start(options \\ []) do
    :ssl.start()
    directory = Path.join(System.tmp_dir!(), "fd-tls-#{System.unique_integer([:positive])}")
    File.mkdir_p!(directory)

    commands = [
      [
        "req",
        "-x509",
        "-newkey",
        "rsa:2048",
        "-nodes",
        "-keyout",
        directory <> "/ca-key.pem",
        "-out",
        directory <> "/ca.pem",
        "-days",
        "1",
        "-subj",
        "/CN=Fixture CA",
        "-addext",
        "basicConstraints=critical,CA:TRUE"
      ],
      [
        "req",
        "-new",
        "-newkey",
        "rsa:2048",
        "-nodes",
        "-keyout",
        directory <> "/key.pem",
        "-out",
        directory <> "/request.pem",
        "-subj",
        "/CN=#{options[:certificate_hostname] || "localhost"}"
      ],
      [
        "x509",
        "-req",
        "-in",
        directory <> "/request.pem",
        "-CA",
        directory <> "/ca.pem",
        "-CAkey",
        directory <> "/ca-key.pem",
        "-CAcreateserial",
        "-out",
        directory <> "/cert.pem",
        "-days",
        "1",
        "-extfile",
        directory <> "/extensions"
      ]
    ]

    File.write!(
      directory <> "/extensions",
      "subjectAltName=DNS:#{options[:certificate_hostname] || "localhost"}\nbasicConstraints=CA:FALSE\nextendedKeyUsage=serverAuth\n"
    )

    for command <- commands do
      {_, 0} = System.cmd("openssl", command, stderr_to_stdout: true)
    end

    {:ok, listener} =
      if options[:handshake_block],
        do: :gen_tcp.listen(0, [:binary, active: false, reuseaddr: true, ip: {127, 0, 0, 1}]),
        else:
          :ssl.listen(0, [
            :binary,
            active: false,
            reuseaddr: true,
            ip: {127, 0, 0, 1},
            certfile: String.to_charlist(directory <> "/cert.pem"),
            keyfile: String.to_charlist(directory <> "/key.pem")
          ])

    {:ok, {_, port}} =
      if options[:handshake_block], do: :inet.sockname(listener), else: :ssl.sockname(listener)

    options =
      Keyword.update(options, :headers, [], fn headers ->
        if is_function(headers, 1), do: headers.(port), else: headers
      end)

    owner = self()
    pid = spawn_link(fn -> loop(listener, owner, options) end)

    %{
      tcp: options[:handshake_block],
      pid: pid,
      listener: listener,
      directory: directory,
      transport: %{
        address: {127, 0, 0, 1},
        port: port,
        hostname: "localhost",
        cacertfile: directory <> "/ca.pem"
      }
    }
  end

  def stop(server) do
    if server.tcp, do: :gen_tcp.close(server.listener), else: :ssl.close(server.listener)
    Process.unlink(server.pid)
    Process.exit(server.pid, :kill)
    File.rm_rf!(server.directory)
  end

  defp loop(listener, owner, options) do
    if options[:handshake_block] do
      case :gen_tcp.accept(listener, 2000) do
        {:ok, socket} ->
          {:ok, _hello} = :gen_tcp.recv(socket, 0, 2000)
          send(owner, {:tls_accepted, self()})
          await_tcp_close(socket, owner)
          :gen_tcp.close(socket)
          loop(listener, owner, options)

        _ ->
          :ok
      end
    else
      accept_tls(listener, owner, options)
    end
  end

  defp await_tcp_close(socket, owner) do
    case :gen_tcp.recv(socket, 0, 2000) do
      {:error, :closed} -> send(owner, {:tls_closed, self()})
      {:ok, _} -> await_tcp_close(socket, owner)
      other -> send(owner, {:tls_not_closed, other})
    end
  end

  defp accept_tls(listener, owner, options) do
    case :ssl.transport_accept(listener, 2000) do
      {:ok, raw} ->
        case :ssl.handshake(raw, 2000) do
          {:ok, socket} -> serve(socket, owner, options)
          _ -> send(owner, {:tls_closed, self()})
        end

        loop(listener, owner, options)

      _ ->
        :ok
    end
  end

  defp serve(socket, owner, options) do
    case :ssl.recv(socket, 0, 2000) do
      {:ok, bytes} ->
        [line | lines] = String.split(bytes, "\r\n", trim: true)
        [method, path, _] = String.split(line, " ")

        headers =
          Map.new(lines, fn line ->
            [k, v] = String.split(line, ":", parts: 2)
            {String.downcase(k), String.trim(v)}
          end)

        send(owner, {:tls_request, method, path, headers})

        {status, response_headers, body} =
          if options[:responder] do
            options[:responder].(path)
          else
            {options[:status] || 200, options[:headers] || [],
             options[:body] ||
               Jason.encode!(FootballMarket.Providers.FootballData.FixtureData.base().discovery)}
          end

        extra = Enum.map_join(response_headers, "", fn {k, v} -> "#{k}: #{v}\r\n" end)

        if options[:raw_response] do
          :ssl.send(socket, options[:raw_response])
        else
          if options[:split_status] do
            :ssl.send(socket, "HTTP/1.1 #{status} Fixture\r\n")
            Process.sleep(20)
          end

          unless options[:block_headers],
            do:
              :ssl.send(
                socket,
                "#{if(options[:split_status], do: "", else: "HTTP/1.1 #{status} Fixture\r\n")}content-length: #{if options[:truncated], do: byte_size(body) + 10, else: byte_size(body)}\r\n#{extra}\r\n"
              )

          unless options[:block_headers] || options[:block_body], do: :ssl.send(socket, body)
        end

        if options[:truncated], do: :ssl.close(socket)

        case :ssl.recv(socket, 0, 2000) do
          {:error, :closed} -> send(owner, {:tls_closed, self()})
          other -> send(owner, {:tls_not_closed, other})
        end

      _ ->
        send(owner, {:tls_closed, self()})
    end

    :ssl.close(socket)
  end
end
