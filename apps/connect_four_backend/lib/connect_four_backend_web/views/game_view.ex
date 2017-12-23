defmodule ConnectFourBackendWeb.GameView do
  use ConnectFourBackendWeb, :view

  ###########
  # Renders #
  ###########

  def render("state.json", %{game_state: game_state, game_id: game_id}) do
    %{
      id: game_id,
      board: %{
        free: board_to_array(game_state.board.free),
        player_1: board_to_array(game_state.board.player_1),
        player_2: board_to_array(game_state.board.player_2)
      },
      height: game_state.height,
      width: game_state.width,
      last_play: check_last_play(game_state.last_play),
      avail_cols: 1..game_state.width |> Enum.to_list,
      current_player: game_state.current_player,
      finished: game_state.finished
    }
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end

  ########################
  # Supporting Functions #
  ########################

  def board_to_array(board) do
    board
    |> MapSet.to_list
    |> Enum.map(&([&1 |> elem(0), &1 |> elem(1)]))
  end

  defp check_last_play(last_play) when is_tuple(last_play) do
    {player, {x, y}} = last_play
    [player, [x, y]]
  end
  defp check_last_play(_), do: nil
end
