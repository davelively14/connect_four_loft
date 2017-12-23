defmodule ConnectFour do
  use Application

  def start do
    import Supervisor.Spec

    children = [
      worker(ConnectFour.GameServer, [])
    ]

    opts = [
      strategy: :one_for_one,
      name: ConnectFour.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
