defmodule ConnectFour.GameServerTest do
  use ExUnit.Case
  alias ConnectFour.GameServer

  describe "get_state/0" do
    test "returns state with default params" do
      state = GameServer.get_state()
      assert is_map state.board
      assert MapSet.size state.board.free
      assert MapSet.size state.board.player_1
      assert MapSet.size state.board.player_2

      assert is_integer state.current_player
      assert !state.finished
    end
  end
end
