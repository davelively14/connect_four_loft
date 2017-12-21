defmodule ConnectFour.AITest do
  use ExUnit.Case
  alias ConnectFour.{AI, GameServer}

  setup do
    GameServer.start_link(%{height: 6, width: 7})
    :ok
  end

  describe "select_column(game_state, :easy)" do
    test "selects center column when nothing has been played yet" do
      assert AI.select_column(GameServer.get_state, :easy) == 4
    end

    test "selects random column when user is not in danger of winning" do
      GameServer.drop_piece(1)
      col = AI.select_column(GameServer.get_state, :easy)
      assert col >= 1 && col <= 7
    end

    test "blocks user if in danger of winning" do
      setup_vert_3()
      assert AI.select_column(GameServer.get_state, :easy) == 1

      GameServer.reset_game()

      setup_lat_3()
      assert AI.select_column(GameServer.get_state, :easy) == 4
    end
  end


  #####################
  # Private Functions #
  #####################

  defp setup_vert_3 do
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
  end

  defp setup_lat_3 do
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(3)
  end
end
