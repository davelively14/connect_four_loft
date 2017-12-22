defmodule ConnectFour do
  use Application

  def start, do: start(nil, %{height: 6, width: 7})
  def start(_type, %{height: height, width: width} \\ %{height: 6, width: 7}) do
    import Supervisor.Spec

    children = [
      worker(ConnectFour.GameServer, [%{height: height, width: width}], [])
    ]

    opts = [
      strategy: :one_for_one,
      name: ConnectFour.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
