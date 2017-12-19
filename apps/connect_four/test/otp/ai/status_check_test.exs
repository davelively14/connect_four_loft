defmodule ConnectFour.StatusCheckTest do
  use ExUnit.Case
  alias ConnectFour.{GameServer, StatusCheck}

  setup context do
    GameServer.start_link(%{height: 6, width: 7})

    cond do
      context[:setup_board_3_vert] -> setup_board_3_vert()
      context[:setup_board_3_lat_mid] -> setup_board_3_lat_mid()
      context[:setup_board_3_lat_left] -> setup_board_3_lat_left()
      context[:setup_board_3_lat_right] -> setup_board_3_lat_right()
      context[:setup_board_3_lat_row_2] -> setup_board_3_lat_row_2()
      true -> nil
    end

    game_state = %{board: board} = GameServer.get_state()
    if game_state.last_play, do: {player, loc} = game_state.last_play
    {:ok, %{game_state: game_state, board: board, player: player, loc: loc}}
  end

  describe "check_vert/3" do
    @describetag :setup_board_3_vert

    test "returns true when consecutive pieces condition met", %{board: board, player: player, loc: loc} do
      assert StatusCheck.check_vert(board, player, loc, 3) == true
    end

    test "does not return column if not enough consecutive pieces", %{board: board, player: player, loc: loc} do
      assert StatusCheck.check_vert(board, player, loc, 4) == false
    end

    test "returns column if more than necessary consecutive pieces", %{board: board, player: player, loc: loc} do
      assert StatusCheck.check_vert(board, player, loc, 2) == true
    end
  end

  describe "check_vert/2" do
    @describetag :setup_board_3_vert

    test "returns true when consecutive pieces condition met", %{game_state: game_state} do
      assert StatusCheck.check_vert(game_state, 3) == true
    end

    test "returns false if not enough consecutive pieces", %{game_state: game_state} do
      assert StatusCheck.check_vert(game_state, 4) == false
    end

    test "returns true if more than necessary consecutive pieces", %{game_state: game_state} do
      assert StatusCheck.check_vert(game_state, 2) == true
    end
  end

  describe "block_vert?/3" do
    @tag :setup_board_3_vert
    test "will return column if available", %{board: board, player: player, loc: loc} do
      assert StatusCheck.block_vert?(board, player, loc) == 1
    end

    test "will return nil if column is already full" do
      GameServer.drop_piece(1)
      GameServer.drop_piece(2)
      GameServer.drop_piece(1)
      GameServer.drop_piece(1)
      GameServer.drop_piece(1)
      GameServer.drop_piece(2)
      GameServer.drop_piece(1)
      GameServer.drop_piece(2)
      GameServer.drop_piece(1)

      %{board: board, last_play: {player, loc}} = GameServer.get_state()
      assert StatusCheck.block_vert?(board, player, loc) == nil
    end
  end

  describe "check_left/4" do
    @tag :setup_board_3_lat_mid
    test "returns correct streak and column for blocking spot", %{board: board, player: player, loc: loc} do
      assert StatusCheck.check_left(board, player, loc, 3) == {2, 1}
    end

    @tag :setup_board_3_lat_left
    test "returns streak and nil column since no block to the left", %{board: board, player: player, loc: loc} do
      assert StatusCheck.check_left(board, player, loc, 3) == {3, nil}
    end
  end

  describe "check_right/4" do
    @tag :setup_board_3_lat_mid
    test "returns correct streak and column for blocking spot", %{board: board, player: player, loc: loc} do
      assert StatusCheck.check_right(board, player, loc, 3) == {2, 6}
    end

    @tag :setup_board_3_lat_right
    test "returns streak and nil column for blocking spot", %{board: board, player: player, loc: loc} do
      assert StatusCheck.check_right(board, player, loc, 3) == {2, 6}
    end
  end

  #####################
  # Private Functions #
  #####################

  defp setup_board_3_vert do
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
  end

  defp setup_board_3_lat_mid do
    GameServer.drop_piece(3)
    GameServer.drop_piece(3)
    GameServer.drop_piece(5)
    GameServer.drop_piece(5)
    GameServer.drop_piece(4)
  end

  defp setup_board_3_lat_left do
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(3)
  end

  defp setup_board_3_lat_right do
    GameServer.drop_piece(7)
    GameServer.drop_piece(7)
    GameServer.drop_piece(6)
    GameServer.drop_piece(6)
    GameServer.drop_piece(5)
  end

  defp setup_board_3_lat_row_2 do
    GameServer.drop_piece(7)
    GameServer.drop_piece(3)
    GameServer.drop_piece(3)
    GameServer.drop_piece(5)
    GameServer.drop_piece(5)
    GameServer.drop_piece(4)
    GameServer.drop_piece(4)
  end
end
