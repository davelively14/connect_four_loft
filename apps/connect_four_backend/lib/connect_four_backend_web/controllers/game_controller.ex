defmodule ConnectFourBackendWeb.GameController do
  use ConnectFourBackendWeb, :controller
  alias ConnectFour.{GameServer, AI}

  def create(conn, opts \\ %{}) do
    opts = map_to_keyword_list(opts)

    case GameServer.new_game(opts) do
      {:ok, game_id} ->
        game_state = GameServer.get_game(game_id)

        conn
        |> put_status(:created)
        |> render("state.json", %{game_state: game_state, game_id: game_id})
      {:error, reason} ->
        render_error(conn, 422, reason)
      _ ->
        render_error(conn, 400, "Unknown error")
    end
  end

  def show(conn, %{"id" => id}) do
    if game_id = ensure_positive_int(id) do
      case game_state = GameServer.get_game(game_id) do
        {:error, reason} ->
          render_error(conn, 422, reason)
        _ ->
        render conn, "state.json", %{game_state: game_state, game_id: game_id}
      end
    else
      render_error(conn, 422, "Invalid format for id")
    end
  end

  def update(conn, %{"id" => game_id, "col" => col}) do
    game_id = ensure_positive_int(game_id)
    col = ensure_positive_int(col)
    game_state = GameServer.get_game(game_id)

    cond do
      game_id && col && is_map(game_state) ->
        difficulty = game_state.difficulty

        case GameServer.drop_piece(game_id, col) do
          {:error, reason} ->
            render_error(conn, 422, reason)
          :ok ->
            if difficulty do
              game_state = GameServer.get_game(game_id)
              cpu_move = AI.select_column(game_state, difficulty)
              GameServer.drop_piece(game_id, cpu_move)
            end

            game_state = GameServer.get_game(game_id)
            render conn, "state.json", %{game_state: game_state, game_id: game_id}
          _ ->
            game_state = GameServer.get_game(game_id)
            render conn, "state.json", %{game_state: game_state, game_id: game_id}
        end
      game_id && col ->
        render_error(conn, 422, game_state |> elem(1))
      true ->
        render_error(conn, 422, "Invalid parameters")
    end
  end

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

  defp render_error(conn, status, reason) do
    conn
    |> put_status(status)
    |> render("error.json", %{error: reason})
  end

  defp map_to_keyword_list(map) do
    Enum.map(map, fn {key, value} ->
      if int_value = ensure_positive_int(value) do
        {String.to_atom(key), int_value}
      else
        {String.to_atom(key), String.to_atom(value)}
      end
    end)
  end
end
