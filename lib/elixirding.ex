defmodule Elixirding do
  @moduledoc """
  钉钉登录Elixir Demo
  """
  # def init([]) do
    IO.puts "start!"
    import Supervisor.Spec, warn: false
    children = [
      supervisor(Elixirding.Web.Supervisor, []),
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  # end
  # def start(_a, _b) do
  # end
end
