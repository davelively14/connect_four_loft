defmodule ConnectFour.StatusCheckTest do
  use ExUnit.Case

  describe "block_opponent?/1" do
    test "will block opponent about to win vertically" do
      setup_vert_win()
      assert AIServer.block_opponent?(GameServer.get_state()) == 1
    end

    test "will block opponenet if about to win laterally" do
      setup_lat_win()
      assert AIServer.block_opponent?(GameServer.get_state()) == 3
    end
  end

  #####################
  # Private Functions #
  #####################

  defp setup_vert_win do
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
  end

  defp setup_lat_win do
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(3)
  end
end
