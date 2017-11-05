defmodule Elixirding.Web.Supervisor do
  use Supervisor
  require Logger
  use Application

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    IO.puts "start!"
    import Supervisor.Spec, warn: false
    start_http()
    children = [ ]
    opts = [strategy: :one_for_one, name: __MODULE__]
    supervise(children, opts)
  end

  defp start_http() do
    http_cfg = Application.get_env(:elixirding, :http)
    IO.inspect http_cfg
    acceptors = Application.get_env(:elixirding, :http_acceptor)
    Plug.Adapters.Cowboy.http Elixirding.RootRouter, [acceptors: acceptors],
      port: http_cfg.listen_port,
      ip:   http_cfg.listen_ip
    IO.puts("start with acceptors: #{acceptors}")
    IO.puts("http server listen at #{inspect(http_cfg)}")
  end
end
