defmodule ConnectFour.StatusCheck do
  @moduledoc """
  Returns statuses of the board.
  """

  @doc """
  Returns a list of columns that would produce a win for the opposing player.
  Can either pass a valid board, player atom, and available columns list, or
  simply pass the game_state

  ## Examples

      iex> get_block_cols(valid_board, :opposing_player, avail_cols)
      [1]
      iex> get_block_cols(valid_board, :opposing_player, avail_cols)
      []
      iex> get_block_cols(valid_game_state)
      [1]
      iex> get_block_cols(valid_game_state)
      []
  """
  def get_block_cols(game_state) do
    if last_play = game_state.last_play do
      get_block_cols(game_state.board, elem(last_play, 0), game_state.avail_cols, [])
    else
      []
    end
  end
  def get_block_cols(board, player, avail_cols), do: get_block_cols(board, player, avail_cols, [])
  defp get_block_cols(_, _, [], to_block), do: to_block
  defp get_block_cols(board, player, [head | tail], to_block) do
    if loc = find_open(board, head) do
      if check_win_or_draw(board, player, loc) == player do
        get_block_cols(board, player, tail, [elem(loc, 0) | to_block])
      else
        get_block_cols(board, player, tail, to_block)
      end
    else
      get_block_cols(board, player, tail, to_block)
    end
  end

  @doc """
  Returns winning player, draw, or nil for a provided board if a piece were to
  be played at a given location.

  ## Examples

      iex> check_win_or_draw(valid_board, :player_1, {1, 4})
      :player_1
      iex> check_win_or_draw(valid_board, :player_1, {4, 1})
      nil
      iex> check_win_or_draw(valid_board, :player_1, {7, 6})
      :draw
  """
  def check_win_or_draw(board, player, loc) do
    cond do
      check_lateral(board[player], loc) -> player
      check_vertical(board[player], loc) -> player
      check_diag_back(board[player], loc) -> player
      check_diag_fwd(board[player], loc) -> player
      MapSet.size(board[:free]) == 0 -> :draw
      true -> nil
    end
  end

  def check_lateral(player_board, {x, y}) do
    check_left(1, player_board, {x - 1, y}) |> check_right(player_board, {x + 1, y}) == 4
  end

  def check_vertical(player_board, {x, y}), do: check_vertical(1, player_board, {x, y - 1})
  defp check_vertical(4, _, _), do: true
  defp check_vertical(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_vertical(streak + 1, player_board, {x, y - 1})
    else
      false
    end
  end

  def check_diag_back(player_board, {x, y}) do
    check_up_left(1, player_board, {x - 1, y + 1}) |> check_down_right(player_board, {x + 1, y - 1}) == 4
  end

  def check_diag_fwd(player_board, {x, y}) do
    check_up_right(1, player_board, {x + 1, y + 1}) |> check_down_left(player_board, {x - 1, y - 1}) == 4
  end

  defp check_left(4, _, _), do: 4
  defp check_left(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_left(streak + 1, player_board, {x - 1, y})
    else
      streak
    end
  end

  defp check_right(4, _, _), do: 4
  defp check_right(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_right(streak + 1, player_board, {x + 1, y})
    else
      streak
    end
  end

  defp check_up_left(4, _, _), do: 4
  defp check_up_left(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_up_left(streak + 1, player_board, {x - 1, y + 1})
    else
      streak
    end
  end

  defp check_down_right(4, _, _), do: 4
  defp check_down_right(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_down_right(streak + 1, player_board, {x + 1, y - 1})
    else
      streak
    end
  end

  defp check_up_right(4, _, _), do: 4
  defp check_up_right(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_up_right(streak + 1, player_board, {x + 1, y + 1})
    else
      streak
    end
  end

  defp check_down_left(4, _, _), do: 4
  defp check_down_left(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_down_left(streak + 1, player_board, {x - 1, y - 1})
    else
      streak
    end
  end

  def find_open(board, col), do: find_open(MapSet.to_list(board[:free]), col, nil)
  defp find_open([], _, lowest), do: lowest
  defp find_open([head | tail], col, lowest) do
    cond do
      elem(head, 0) == col && (lowest && elem(head, 1) < elem(lowest, 1) || !lowest) ->
        find_open(tail, col, head)
      true ->
        find_open(tail, col, lowest)
    end
  end
end