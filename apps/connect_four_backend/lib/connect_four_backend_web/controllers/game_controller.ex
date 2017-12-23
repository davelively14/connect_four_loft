defmodule ConnectFourBackendWeb.GameController do
  use ConnectFourBackendWeb, :controller
  alias ConnectFour.GameServer

  def create(conn, %{"width" => width, "height" => height}) do
    height = ensure_positive_int(height)
    width = ensure_positive_int(width)

    if :erlang.whereis(ConnectFour) == :undefined do
      ConnectFour.start()
    end

    if height && width do
      {:ok, game_id} = GameServer.new_game(height, width)
      game_state = GameServer.get_game(game_id)
      conn
      |> put_status(201)
      |> render "state.json", %{game_state: game_state, game_id: game_id}
    else
      conn
      |> put_status(422)
      |> render "error.json", %{error: "Invalid parameters"}
    end
  end
  def create(conn, _), do: create(conn, %{"width" => 7, "height" => 6})

  #####################
  # Private Functions #
  #####################

  defp ensure_positive_int(value) when is_integer(value), do: value
  defp ensure_positive_int(value) do
    case Integer.parse(value) do
      {num, ""} ->
        if num > 0, do: num, else: nil
      _ ->
        nil
    end
  end
end
