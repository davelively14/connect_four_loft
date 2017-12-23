defmodule CLI do
  use Application

  def start, do: start(nil, nil)
  def start(_type, _params) do
    import Supervisor.Spec

    children = [
      worker(ConnectFour.GameServer, [], [])
    ]

    options = [
      strategy: :one_for_one,
      name: CLI.Supervisor
    ]

    Supervisor.start_link(children, options)
    CLI.Server.start
  end
end
