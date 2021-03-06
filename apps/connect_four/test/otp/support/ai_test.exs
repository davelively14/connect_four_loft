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

    test "blocks opponent if in danger of losing", %{game_id: game_id} do
      setup_vert_3_block(game_id)
      assert AI.select_column(GameServer.get_game(game_id), :easy) == 1

      GameServer.reset_game(game_id)

      setup_lat_3_block(game_id)
      assert AI.select_column(GameServer.get_game(game_id), :easy) == 4
    end
  end

  describe "select_column(game_state, :hard)" do
    test "selects center column when nothing has been played yet", %{game_id: game_id} do
      assert AI.select_column(GameServer.get_game(game_id), :hard) == 4
    end

    test "blocks opponent if in danger of losing", %{game_id: game_id} do
      setup_vert_3_block(game_id)
      assert AI.select_column(GameServer.get_game(game_id), :hard) == 1

      GameServer.reset_game(game_id)

      setup_lat_3_block(game_id)
      assert AI.select_column(GameServer.get_game(game_id), :hard) == 4
    end

    test "wins if it's possible to win", %{game_id: game_id} do
      setup_vert_3_win(game_id)
      assert AI.select_column(GameServer.get_game(game_id), :hard) == 1

      GameServer.reset_game(game_id)

      setup_lat_3_win(game_id)
      assert AI.select_column(GameServer.get_game(game_id), :hard) == 4
    end

    test "plays a column", %{game_id: game_id} do
      GameServer.drop_piece(game_id, 4)
      assert is_integer(AI.select_column(GameServer.get_game(game_id), :hard))
    end

    test "doesn't get trapped easy lateral", %{game_id: game_id} do
      GameServer.drop_piece(game_id, 4)
      GameServer.drop_piece(game_id, 4)
      GameServer.drop_piece(game_id, 3)
      col = AI.select_column(GameServer.get_game(game_id), :hard)

      assert col == 2 || col == 5
    end

    test "doesn't get trapped in a complex lateral", %{game_id: game_id} do
      GameServer.drop_piece(game_id, 4)
      GameServer.drop_piece(game_id, 4)
      GameServer.drop_piece(game_id, 2)

      assert AI.select_column(GameServer.get_game(game_id), :hard) == 3
    end
  end

  #####################
  # Private Functions #
  #####################

  defp setup_vert_3_block(game_id) do
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
  end

  defp setup_vert_3_win(game_id) do
    setup_vert_3_block(game_id)
    GameServer.drop_piece(game_id, 2)
  end

  defp setup_lat_3_block(game_id) do
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 3)
  end

  defp setup_lat_3_win(game_id) do
    setup_lat_3_block(game_id)
    GameServer.drop_piece(game_id, 3)
  end
end
