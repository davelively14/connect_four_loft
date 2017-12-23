defmodule ConnectFour.AITest do
  use ExUnit.Case
  alias ConnectFour.{AI, GameServer}

  setup do
    GameServer.start_link()
    {:ok, game_id} = GameServer.new_game()

    {:ok, %{game_id: game_id}}
  end

  describe "select_column(game_state, :easy)" do
    test "selects center column when nothing has been played yet", %{game_id: game_id} do
      assert AI.select_column(GameServer.get_game(game_id), :easy) == 4
    end

    test "selects random column when user is not in danger of winning", %{game_id: game_id} do
      GameServer.drop_piece(game_id, 1)
      col = AI.select_column(GameServer.get_game(game_id), :easy)
      assert col >= 1 && col <= 7
    end

    test "blocks user if in danger of winning", %{game_id: game_id} do
      setup_vert_3(game_id)
      assert AI.select_column(GameServer.get_game(game_id), :easy) == 1

      GameServer.reset_game(game_id)

      setup_lat_3(game_id)
      assert AI.select_column(GameServer.get_game(game_id), :easy) == 4
    end
  end


  #####################
  # Private Functions #
  #####################

  defp setup_vert_3(game_id) do
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
  end

  defp setup_lat_3(game_id) do
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 3)
  end
end
