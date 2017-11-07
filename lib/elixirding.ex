defmodule Elixirding do
  @moduledoc """
   钉钉登录Elixir Demo
  """
  use Application

  # def start(_type, _args) do
  IO.puts "start:"
  import Supervisor.Spec, warn: false
  children = [
    supervisor(Elixirding.Web.Supervisor, []),
  ]

  opts = [strategy: :one_for_one]
  Supervisor.start_link(children, opts)
  # end
end
