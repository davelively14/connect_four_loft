defmodule ConnectFour.StatusCheckTest do
  use ExUnit.Case
  alias ConnectFour.{GameServer, StatusCheck}

  setup context do
    GameServer.start_link(%{height: 6, width: 7})

    cond do
      context[:setup_board_vert] -> setup_board_vert()
      context[:setup_board_lat] -> setup_board_lat()
      context[:setup_board_diag_back] -> setup_board_diag_back()
      context[:setup_board_diag_fwd] -> setup_board_diag_fwd()
      context[:setup_board_full] -> setup_board_full()
      true -> nil
    end

    game_state = %{board: board} = GameServer.get_state()

    {player, loc} =
      if game_state.last_play, do: game_state.last_play, else: {nil, nil}

    {:ok, %{game_state: game_state, board: board, player: player, loc: loc}}
  end

  describe "check_lateral/2" do
    @describetag :setup_board_lat

    test "returns true when a player's piece at loc would win laterally", %{board: board, player: player} do
      assert StatusCheck.check_lateral(board[player], {6,1})
      assert StatusCheck.check_lateral(board[player], {2,1})
    end

    test "returns false when a player's piece at loc would not win laterally", %{board: board, player: player} do
      refute StatusCheck.check_lateral(board[player], {1,1})
      refute StatusCheck.check_lateral(board[player], {7,1})
      refute StatusCheck.check_lateral(board[player], {3,1})
      refute StatusCheck.check_lateral(board[player], {4,1})
      refute StatusCheck.check_lateral(board[player], {5,1})
    end
  end

  describe "check_vertical/2" do
    @describetag :setup_board_vert

    test "returns true when a player's piece at loc would win vertically", %{board: board, player: player} do
      assert StatusCheck.check_vertical(board[player], {1,4})
    end

    test "returns false when a player's piece at loc would not win laterally", %{board: board, player: player} do
      refute StatusCheck.check_vertical(board[player], {1,3})
      refute StatusCheck.check_vertical(board[player], {2,1})
      refute StatusCheck.check_vertical(board[player], {6,6})
    end
  end

  describe "check_diag_back/2" do
    @describetag :setup_board_diag_back

    test "returns true when a player's piece at loc would win diagonally back", %{board: board, player: player} do
      assert StatusCheck.check_diag_back(board[player], {1,4})
    end

    test "returns false when a player's piece at loc would not win diagonally back", %{board: board, player: player} do
      refute StatusCheck.check_diag_back(board[player], {2,4})
      refute StatusCheck.check_diag_back(board[player], {3,3})
      refute StatusCheck.check_diag_back(board[player], {4,2})
    end
  end

  describe "check_diag_fwd/2" do
    @describetag :setup_board_diag_fwd

    test "returns true when a player's piece at loc would win diagonally back", %{board: board, player: player} do
      assert StatusCheck.check_diag_fwd(board[player], {4,4})
    end

    test "returns false when a player's piece at loc would not win diagonally back", %{board: board, player: player} do
      refute StatusCheck.check_diag_fwd(board[player], {3,4})
    end
  end

  #####################
  # Private Functions #
  #####################

  defp setup_board_vert do
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
  end

  defp setup_board_lat do
    GameServer.drop_piece(3)
    GameServer.drop_piece(3)
    GameServer.drop_piece(4)
    GameServer.drop_piece(4)
    GameServer.drop_piece(5)
  end

  defp setup_board_diag_back do
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(4)
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(3)
    GameServer.drop_piece(3)
    GameServer.drop_piece(7)
    GameServer.drop_piece(3)
  end

  defp setup_board_diag_fwd do
    GameServer.drop_piece(4)
    GameServer.drop_piece(4)
    GameServer.drop_piece(4)
    GameServer.drop_piece(3)
    GameServer.drop_piece(1)
    GameServer.drop_piece(3)
    GameServer.drop_piece(3)
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(7)
    GameServer.drop_piece(2)
  end

  defp setup_board_full do
    for outer <- 0..1 do
      for x <- 1..3 do
        for _ <- 0..4 do
          GameServer.drop_piece(x + outer * 3)
        end
      end
      for x <- 1..3 do
        GameServer.drop_piece(x + outer * 3)
      end
    end
    for _ <- 1..6 do
      GameServer.drop_piece(7)
    end
    |> List.flatten()
    |> List.last()
  end
end
