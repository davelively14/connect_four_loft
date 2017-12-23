defmodule ConnectFourBackendWeb.GameController do
  use ConnectFourBackendWeb, :controller
  alias ConnectFour.GameServer

  def create(conn, %{"width" => width, "height" => height}) do
    height = ensure_int(height)
    width = ensure_int(width)

    if :erlang.whereis(ConnectFour) == :undefined do
      ConnectFour.start()
    end

    {:ok, game_id} =
      if height && width do
        GameServer.new_game(height, width)
      else
        GameServer.new_game
      end

    game_state = GameServer.get_game(game_id)
    render conn, "state.json", %{game_state: game_state, game_id: game_id}
  end
  def create(conn, _), do: create(conn, %{"width" => 7, "height" => 6})

  #####################
  # Private Functions #
  #####################

  defp ensure_int(value) when is_integer(value), do: value
  defp ensure_int(value) do
    case Integer.parse(value) do
      {num, ""} ->
        num
      _ ->
        nil
    end
  end
end
