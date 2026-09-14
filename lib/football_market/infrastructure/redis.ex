defmodule FootballMarket.Infrastructure.Redis do
  @moduledoc "Application-owned Redis connectivity boundary; it stores no data."

  def start_link(config) do
    opts = [host: config.host, port: config.port, sync_connect: true, socket_opts: [:inet]]
    opts = if config.password, do: Keyword.put(opts, :password, config.password), else: opts
    Redix.start_link(opts)
  end

  def ping(client), do: Redix.command(client, ["PING"])
end
