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

  # Strategy:
  # 1. If win available, win
  # 2. If opponent could win, block
  # 3. Heuristically select best move available
  def select_column(game_state, :hard) do
    cond do
      col = StatusCheck.get_win_col(game_state) ->
        col
      col = StatusCheck.get_block_cols(game_state) ->
        col
      !game_state.last_play ->
        div(game_state.width + 1, 2)
      true ->
        # TODO: replace with heuristic solution
        Enum.random(game_state.avail_cols)
    end
  end
end
