use Mix.Config

config :elixirding, [
  http_acceptor: 8,
  http: %{
    listen_ip: {0, 0, 0, 0},
    listen_port: 4444,
  },
]
