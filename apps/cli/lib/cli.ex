defmodule CLI do
  use Application

  @height 6
  @width 7

  def start(_type, _params) do
    import Supervisor.Spec

    children = [
      worker(ConnectFour.GameServer, [%{height: @height, width: @width}], [])
    ]

    options = [
      strategy: :one_for_one,
      name: CLI.Supervisor
    ]

    Supervisor.start_link(children, options)
    CLI.Server.start
  end
end
