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

    test "returns column when consecutive pieces met", %{board: board, player: player, loc: loc} do
      assert StatusCheck.check_vert(board, player, loc, 3) == 1
    end

    test "does not return column if not enough consecutive pieces", %{board: board, player: player, loc: loc} do
      refute StatusCheck.check_vert(board, player, loc, 4)
    end

    test "returns column if more than necessary consecutive pieces", %{board: board, player: player, loc: loc} do
      assert StatusCheck.check_vert(board, player, loc, 2) == 1
    end
  end

  describe "check_vert/2" do
    @describetag :setup_board_3_vert

    test "returns column when consecutive pieces met", %{game_state: game_state} do
      assert StatusCheck.check_vert(game_state, 3) == 1
    end

    test "does not return column if not enough consecutive pieces", %{game_state: game_state} do
      refute StatusCheck.check_vert(game_state, 4)
    end

    test "returns column if more than necessary consecutive pieces", %{game_state: game_state} do
      assert StatusCheck.check_vert(game_state, 2) == 1
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
