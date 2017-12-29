defmodule ConnectFour.AI do
  alias ConnectFour.StatusCheck

  #######
  # API #
  #######

  def select_column(game_state, :easy) do
    if game_state.last_play do
      if block = StatusCheck.get_block_cols(game_state) do
        block
      else
        Enum.random(game_state.avail_cols)
      end
    else
      div(game_state.width + 1, 2)
    end
  end

  def select_column(game_state, :hard) do
    cond do
      !game_state.last_play ->
        div(game_state.width + 1, 2)
      col = StatusCheck.get_win_col(game_state) ->
        col
      col = StatusCheck.get_block_cols(game_state) ->
        col
      true ->
        best_col(game_state)
    end
  end

  #####################
  # Private Functions #
  #####################

  defp best_col(game_state), do: best_col(game_state.avail_cols, game_state, nil)
  defp best_col([], _, {col, _}), do: col
  defp best_col([head | tail], game_state = %{board: board}, best) do
    best_score = if best, do: best |> elem(1), else: nil

    if loc = StatusCheck.find_open(board, head) do
      score = StatusCheck.score(game_state, loc)

      cond do
        !best_score ->
          best_col(tail, game_state, {head, score})
        score && score > best_score ->
          best_col(tail, game_state, {head, score})
        true ->
          best_col(tail, game_state, best)
      end
    else
      best_col(tail, game_state, best)
    end
  end
end
