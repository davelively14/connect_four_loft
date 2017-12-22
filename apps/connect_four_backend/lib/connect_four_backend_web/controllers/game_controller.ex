defmodule ConnectFourBackendWeb.GameController do
  use ConnectFourBackendWeb, :controller
  alias ConnectFour.GameServer

  def create(conn, %{"width" => width, "height" => height}) do
    height = ensure_int(height)
    width = ensure_int(width)

    if :erlang.whereis(ConnectFour) == :undefined do
      ConnectFour.start(nil, %{height: height, width: width})
    else
      GameServer.new_game(height, width)
    end

    game_state = GameServer.get_state()
    render conn, "state.json", game_state
  end
  def create(conn, _), do: create(conn, %{"width" => 7, "height" => 6})

  #####################
  # Private Functions #
  #####################

  defp ensure_int(value) do
    if is_bitstring(value), do: String.to_integer(value), else: value
  end
end
