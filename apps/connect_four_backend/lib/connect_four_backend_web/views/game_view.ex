defmodule ConnectFourBackendWeb.GameView do
  use ConnectFourBackendWeb, :view

  def render("state.json", game_state) do
    %{
      board: %{
        free: board_to_array(game_state.board.free),
        player_1: board_to_array(game_state.board.player_1),
        player_2: board_to_array(game_state.board.player_2)
      },
      height: game_state.height,
      width: game_state.width,
      last_play: game_state.last_play,
      avail_cols: 1..game_state.width |> Enum.to_list,
      current_player: game_state.current_player,
      finished: game_state.finished
    }
  end

  def board_to_array(board) do
    board
    |> MapSet.to_list
    |> Enum.map(&([&1 |> elem(0), &1 |> elem(1)]))
  end
end
