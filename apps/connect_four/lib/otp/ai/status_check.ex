defmodule ConnectFour.StatusCheck do
  @moduledoc """
  Returns statuses of the board.
  """

  @doc """
  Returns true if there is a contiguous number of pieces for the given distance
  from a given location. Returns false if distance not reached. Can pass the
  board, player, location, and distance to the check_vert/4 function or, if just
  checking the most recent move, a valid game_state and distance to
  check_vert/2.

  ## Examples

      iex> check_vert(valid_board, :player_1, {1, 4}, 3)
      true
      iex> check_vert(valid_game_state, 3)
      true
  """
  def check_vert(state, distance) do
    {player, loc} = state.last_play
    _check_vert(0, state.board[player], loc, distance)
  end
  def check_vert(board, player, loc, distance), do: _check_vert(0, board[player], loc, distance)
  defp _check_vert(streak, _, {_, _}, distance) when streak == distance, do: true
  defp _check_vert(streak, player_board, loc = {x, y}, distance) do
    if MapSet.member?(player_board, loc) do
      _check_vert(streak + 1, player_board, {x, y - 1}, distance)
    else
      false
    end
  end

  @doc """
  Returns column to block if needed. If no block needed, returns nil.

  ## Examples

      iex> block_vert?(valid_board, :player_1, {1, 4})
      1
      iex> block_vert?(valid_bard, :player_1, {2, 2})
      nil
      iex> block_vert?(valid_board, :player_1, {1, 6})
      nil
  """
  def block_vert?(board, player, loc = {x, y}) do
    if check_vert(board, player, loc, 3) && MapSet.member?(board.free, {x, y + 1}) do
      x
    else
      nil
    end
  end
end
