defmodule ConnectFour.StatusCheckTest do
  use ExUnit.Case
  alias ConnectFour.{GameServer, StatusCheck}

  setup context do
    GameServer.start_link(%{height: 6, width: 7})

    cond do
      context[:setup_board_3_vert] ->
        setup_board_3_vert()
        game_state = %{board: board, last_play: {player, loc}} = GameServer.get_state()
        {:ok, %{game_state: game_state, board: board, player: player, loc: loc}}
      context[:setup_board_3_lat] ->
        setup_board_3_lat()
        game_state = %{board: board, last_play: {player, loc}} = GameServer.get_state()
        {:ok, %{game_state: game_state, board: board, player: player, loc: loc}}
      true ->
        :ok
    end
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

  defp setup_board_3_lat do
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(3)
  end
end
