defmodule ConnectFour.StatusCheck do
  @moduledoc """
  Returns statuses of the board.
  """

  @doc """
  Returns a list of columns that would produce a win for the opposing player.

  ## Examples

      iex> must_block(valid_board, :opposing_player, avail_cols)
      [1]
      iex> must_block(valid_board, :opposing_player, avail_cols)
      []
  """
  # def must_block(board, player, avail_cols) do
  #   # check
  # end
  #
  # def check_win_or_draw(player, free, player_board, loc) do
  #   cond do
  #     check_lateral(player_board, loc) -> player
  #     check_vertical(player_board, loc) -> player
  #     check_diag_back(player_board, loc) -> player
  #     check_diag_fwd(player_board, loc) -> player
  #     MapSet.size(free) == 0 -> :draw
  #     true -> nil
  #   end
  # end

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
end
