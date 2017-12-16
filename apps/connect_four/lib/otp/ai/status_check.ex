defmodule ConnectFour.StatusCheck do
  @moduledoc """
  Returns statuses of the board.
  """

  @doc """
  Returns column if there is a contiguous number of pieces for a given distance
  from a given location. Returns nil if

  ## Examples

      iex> check_vert(#MapSet<[{1, 4}, {1, 3}, {1, 2}]>, {1, 4}, 3)
      1
      iex> check_vert(#MapSet<[{1, 4}, {1, 3}, {1, 1}]>, {1, 4}, 3)
      nil
  """
  def check_vert(player_board, loc, distance), do: check_vert(0, player_board, loc, distance)
  defp check_vert(streak, _, {x, _}, distance) when streak == distance, do: x
  defp check_vert(streak, player_board, loc = {x, y}, distance) do
    if MapSet.member?(player_board, loc) do
      check_vert(streak + 1, player_board, {x, y - 1}, distance)
    else
      nil
    end
  end
end
