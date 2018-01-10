defmodule ConnectFour.StatusCheck do
  @moduledoc """
  Returns statuses of the board.
  """

  @doc """
  Provided game_state, will return column that would produce a win for the
  opposing player. If no blocking move necessary, will return nil.

  ## Examples

      iex> get_block_col(valid_game_state)
      1
      iex> get_block_col(valid_game_state)
      nil
  """
  def get_block_col(game_state) do
    if last_play = game_state.last_play do
      get_block_col(game_state.board, elem(last_play, 0), game_state.avail_cols)
    else
      nil
    end
  end
  defp get_block_col(_, _, []), do: nil
  defp get_block_col(board, player, [head | tail]) do
    if loc = find_open(board, head) do
      if check_win_or_draw(board, player, loc) == player do
        elem(loc, 0)
      else
        get_block_col(board, player, tail)
      end
    else
      get_block_col(board, player, tail)
    end
  end

  @doc """
  Provided a valid game state, will determine if a move is available that would
  win the game for the current player and return the column necessary to win.
  Otherwise, returns nil.

  ## Examples

      iex> get_win_col(valid_game_state)
      3
      iex> get_win_col(valid_game_state)
      nil
  """
  def get_win_col(game_state), do: get_win_col(game_state.board, game_state.current_player, game_state.avail_cols)
  defp get_win_col(_, _, []), do: nil
  defp get_win_col(board, player, [head | tail]) do
    if loc = find_open(board, head) do
      if check_win_or_draw(board, player, loc) == player do
        elem(loc, 0)
      else
        get_win_col(board, player, tail)
      end
    else
      get_win_col(board, player, tail)
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

  @doc """
  Returns the next avail location for a given column. If the column is full,
  will return nil.

  ## Examples

      iex> find_open(valid_board, 1)
      {1, 3}
      iex> find_open(valid_board, 3)
      nil
  """
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

  @doc """
  Returns the score for playing a given location. Positive indicates a generally
  good move, zero is neutral, and negative is in favor of the opposing player.

  ## Examples

      iex> score(game_state, {1, 4})
      150
      iex> score(game_state, {2, 2})
      -1000
  """
  def score(game_state, loc = {_x, y}) do

    # Creates a list that be the length of available rows in a column. If the
    # location we're assessing is column 1, row 3 for a standard 6 row game
    # board, then the resulting list would be [1, 2, 3, 4]
    iterations =
      Range.new(1, game_state.height - y + 1)
      |> Enum.to_list

    score(game_state, loc, iterations, 0)
  end
  defp score(_, _, [], score), do: score
  defp score(game_state, loc = {x, y}, [head | tail], tallied_score) do
    player = game_state.current_player
    opp = elem(game_state.last_play, 0)

    player_board = game_state.board[player]
    opp_board = game_state.board[opp]

    cond do
      # Look ahead to prevent situations where an opponent has two ways to
      # win laterally. Example, O would need to play either col 3 or 6 to
      # prevent X from playing either of those next turn and guaranteeing X
      # a win.
      # O - - X X - -
      head == 1 && check_sandwich(opp_board, game_state.board.free, loc) ->
        1000

      # Negatively scores situations where you might setup an opponent win
      # Example, columns 2 and 6 would not be a wise play for player O:
      # O - X X X - -
      # O - O X X - -
      rem(head, 2) == 0 && check_win_or_draw(game_state.board, opp, loc) ->
        div(-2000, head)

      # Negatively scores situations where you eliminate a chance to win.
      # Example, if player O plays cols 2 or 6, X would block:
      # X - O O O - -
      # X - O X X - -
      rem(head, 2) == 0 && check_win_or_draw(game_state.board, player, loc) ->
        div(-1000, head)

      # Generic scoring methods. These numbers will generally be very low and
      # only be relevant as a tiebreaker if none or more than one of the earlier
      # conditions fire. The first function is for even distance from the
      # first free cell, the second function for odd. Generally speaking, odd
      # favors the current player and even the opponent.
      rem(head, 2) == 0 ->
        this_score =
          (lateral_chain_length(player_board, loc) - lateral_chain_length(opp_board, loc) * 2) +
          (check_vertical(player_board, loc, :max) - check_vertical(opp_board, loc, :max) * 2) +
          (diag_back_chain_length(player_board, loc) - diag_back_chain_length(opp_board, loc) * 2)

        score(game_state, {x, y + 1}, tail, tallied_score + this_score)
      rem(head, 2) == 1 ->
        this_score =
          (lateral_chain_length(player_board, loc) * 2 - lateral_chain_length(opp_board, loc)) +
          (check_vertical(player_board, loc, :max) * 2 - check_vertical(opp_board, loc, :max)) +
          (diag_back_chain_length(player_board, loc) * 2 - diag_back_chain_length(opp_board, loc))

        score(game_state, {x, y + 1}, tail, tallied_score + this_score)
      true ->
        # This condition should never be met
        :error
    end
  end

  def check_sandwich(opp_board, free, {x, y}) do
    left = check_left(0, opp_board, {x - 1, y}, :max)
    right = check_right(0, opp_board, {x + 1, y}, :max)

    if left + right > 1 && MapSet.member?(free, {x - left - 1, y}) && MapSet.member?(free, {x + right + 1, y}) do
      true
    else
      false
    end
  end

  def check_lateral(player_board, {x, y}) do
    check_left(1, player_board, {x - 1, y}) |> check_right(player_board, {x + 1, y}) == 4
  end

  def check_diag_back(player_board, {x, y}) do
    check_up_left(1, player_board, {x - 1, y + 1}) |> check_down_right(player_board, {x + 1, y - 1}) == 4
  end

  def check_diag_fwd(player_board, {x, y}) do
    check_up_right(1, player_board, {x + 1, y + 1}) |> check_down_left(player_board, {x - 1, y - 1}) == 4
  end

  def check_vertical(player_board, {x, y}), do: check_vertical(1, player_board, {x, y - 1}, 4)
  def check_vertical(player_board, {x, y}, max), do: check_vertical(1, player_board, {x, y - 1}, max)
  defp check_vertical(streak, _, _, max) when streak == max, do: true
  defp check_vertical(streak, player_board, loc = {x, y}, max) do
    cond do
      MapSet.member?(player_board, loc) ->
        check_vertical(streak + 1, player_board, {x, y - 1}, max)
      is_integer(max) ->
        false
      true ->
        streak
    end
  end

  def lateral_chain_length(player_board, {x, y}) do
    check_left(1, player_board, {x - 1, y}, :max) |> check_right(player_board, {x + 1, y}, :max)
  end

  def diag_back_chain_length(player_board, {x, y}) do
    check_up_left(1, player_board, {x - 1, y + 1}, :max) |> check_down_right(player_board, {x + 1, y - 1}, :max)
  end

  def diag_fwd_chain_length(player_board, {x, y}) do
    check_up_right(1, player_board, {x + 1, y + 1}, :max) |> check_down_left(player_board, {x - 1, y - 1}, :max)
  end

  defp check_left(streak, player_board, loc), do: check_left(streak, player_board, loc, 4)
  defp check_left(streak, _, _, max) when streak == max, do: streak
  defp check_left(streak, player_board, loc = {x, y}, max) do
    if MapSet.member?(player_board, loc) do
      check_left(streak + 1, player_board, {x - 1, y}, max)
    else
      streak
    end
  end

  defp check_right(streak, player_board, loc), do: check_right(streak, player_board, loc, 4)
  defp check_right(streak, _, _, max) when streak == max, do: streak
  defp check_right(streak, player_board, loc = {x, y}, max) do
    if MapSet.member?(player_board, loc) do
      check_right(streak + 1, player_board, {x + 1, y}, max)
    else
      streak
    end
  end

  defp check_up_left(streak, player_board, loc), do: check_up_left(streak, player_board, loc, 4)
  defp check_up_left(streak, _, _, max) when streak == max, do: streak
  defp check_up_left(streak, player_board, loc = {x, y}, max) do
    if MapSet.member?(player_board, loc) do
      check_up_left(streak + 1, player_board, {x - 1, y + 1}, max)
    else
      streak
    end
  end

  defp check_down_right(streak, player_board, loc), do: check_down_right(streak, player_board, loc, 4)
  defp check_down_right(streak, _, _, max) when streak == max, do: streak
  defp check_down_right(streak, player_board, loc = {x, y}, max) do
    if MapSet.member?(player_board, loc) do
      check_down_right(streak + 1, player_board, {x + 1, y - 1}, max)
    else
      streak
    end
  end

  defp check_up_right(streak, player_board, loc), do: check_up_right(streak, player_board, loc, 4)
  defp check_up_right(streak, _, _, max) when streak == max, do: streak
  defp check_up_right(streak, player_board, loc = {x, y}, max) do
    if MapSet.member?(player_board, loc) do
      check_up_right(streak + 1, player_board, {x + 1, y + 1}, max)
    else
      streak
    end
  end

  defp check_down_left(streak, player_board, loc), do: check_down_left(streak, player_board, loc, 4)
  defp check_down_left(streak, _, _, max) when streak == max, do: streak
  defp check_down_left(streak, player_board, loc = {x, y}, max) do
    if MapSet.member?(player_board, loc) do
      check_down_left(streak + 1, player_board, {x - 1, y - 1}, max)
    else
      streak
    end
  end
end
