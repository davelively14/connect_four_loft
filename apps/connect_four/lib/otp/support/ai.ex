defmodule ConnectFour.AI do
  alias ConnectFour.StatusCheck

  #######
  # API #
  #######

  def select_column(game_state, :easy) do
    if game_state.last_play do
      block = StatusCheck.get_block_cols(game_state)
      if length(block) > 0 do
        Enum.random(block)
      else
        Enum.random(game_state.avail_cols)
      end
    else
      div(game_state.width + 1, 2)
    end
  end
end
