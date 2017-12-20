defmodule ConnectFour.StatusCheck do
  @moduledoc """
  Returns statuses of the board.
  """

  @doc """
  Returns a list of columns that would produce a win for the opposing player.

  ## Examples

      iex> get_blocks(valid_board, :opposing_player, avail_cols)
      [1]
      iex> get_blocks(valid_board, :opposing_player, avail_cols)
      []
  """
  # def get_blocks(board, player, avail_cols), do: get_blocks(board, player, avail_cols, [])
  # defp get_blocks(_, _, [], to_block), do: to_block
  # defp get_blocks(board, player, [head | tail], to_block) do
  #   result = check_win_or_draw(board, player, find_open(board[:free], head))
  #   # cond do
  #   #
  #   # end
  # end

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
