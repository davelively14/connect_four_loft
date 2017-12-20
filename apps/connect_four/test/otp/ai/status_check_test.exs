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

    game_state = %{board: board, avail_cols: avail_cols} = GameServer.get_state()

    {player, loc} =
      if game_state.last_play, do: game_state.last_play, else: {:player_1, nil}

    {:ok, %{game_state: game_state, board: board, player: player, loc: loc, avail_cols: avail_cols}}
  end

  describe "get_block_cols/3" do
    @tag :setup_board_vert
    test "returns correct column required for blocking vertically", %{board: board, player: player, avail_cols: avail_cols} do
      assert StatusCheck.get_block_cols(board, player, avail_cols) == [1]
    end

    @tag :setup_board_lat
    test "returns multiple columns for blocking when multiple ways to win", %{board: board, player: player, avail_cols: avail_cols} do
      result = StatusCheck.get_block_cols(board, player, avail_cols)

      assert result == [2, 6] || result == [6, 2]
    end

    @tag :setup_board_diag_back
    test "returns column for blocking a diagonal back", %{board: board, player: player, avail_cols: avail_cols} do
      assert StatusCheck.get_block_cols(board, player, avail_cols) == [1]
    end

    @tag :setup_board_diag_fwd
    test "returns column for blocking a diagonal forward", %{board: board, player: player, avail_cols: avail_cols} do
      assert StatusCheck.get_block_cols(board, player, avail_cols) == [4]
    end

    @tag :setup_board_full
    test "returns empty list if board is full", %{board: board, player: player, avail_cols: avail_cols} do
      assert StatusCheck.get_block_cols(board, player, avail_cols) == []
    end

    test "returns empty list if no threat to win", %{board: board, player: player, avail_cols: avail_cols} do
      assert StatusCheck.get_block_cols(board, player, avail_cols) == []
    end
  end

  describe "get_block_cols/1" do
    test "returns empty list if new board or no threat to win", %{game_state: game_state} do
      assert StatusCheck.get_block_cols(game_state) == []
    end

    @tag :setup_board_vert
    test "returns correct column required for blocking vertically", %{game_state: game_state} do
      assert StatusCheck.get_block_cols(game_state) == [1]
    end

    @tag :setup_board_lat
    test "returns multiple columns for blocking when multiple ways to win", %{game_state: game_state} do
      result = StatusCheck.get_block_cols(game_state)

      assert result == [2, 6] || result == [6, 2]
    end
  end

  describe "check_win_or_draw/3" do
    @tag :setup_board_vert
    test "returns player when a player's piece at loc would win vertically", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {1,4}) == player
    end

    @tag :setup_board_vert
    test "returns nil when a player's piece at loc would not win vertically", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {1,3}) == nil
    end

    @tag :setup_board_lat
    test "returns player when a player's piece at loc would win laterally", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {6,1}) == player
      assert StatusCheck.check_win_or_draw(board, player, {2,1}) == player
    end

    @tag :setup_board_lat
    test "returns nil when a player's piece at loc would not win laterally", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {1,1}) == nil
      assert StatusCheck.check_win_or_draw(board, player, {7,1}) == nil
      assert StatusCheck.check_win_or_draw(board, player, {3,1}) == nil
    end

    @tag :setup_board_diag_back
    test "returns player when a player's piece at loc would win diagonally backward", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {1,4}) == player
    end

    @tag :setup_board_diag_back
    test "returns nil when a player's piece at loc would not win diagonally backward", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {2,4}) == nil
      assert StatusCheck.check_win_or_draw(board, player, {3,3}) == nil
    end

    @tag :setup_board_diag_fwd
    test "returns player when a player's piece at loc would win diagonally forward", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {4,4}) == player
    end

    @tag :setup_board_diag_fwd
    test "returns nil when a player's piece at loc would not win diagonally forward", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {3,4}) == nil
    end

    @tag :setup_board_full
    test "returns :draw when a player's piece at loc would end in a draw", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {3,4}) == :draw
    end
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

  describe "find_open/2" do
    test "returns correct column on an empty board", %{board: board} do
      assert StatusCheck.find_open(board, 1) == {1, 1}
      assert StatusCheck.find_open(board, 3) == {3, 1}
    end

    @tag :setup_board_vert
    test "returns correct column with some pieces in place", %{board: board} do
      assert StatusCheck.find_open(board, 1) == {1, 4}
      assert StatusCheck.find_open(board, 2) == {2, 3}
      assert StatusCheck.find_open(board, 3) == {3, 1}
      assert StatusCheck.find_open(board, 4) == {4, 1}
      assert StatusCheck.find_open(board, 5) == {5, 1}
      assert StatusCheck.find_open(board, 6) == {6, 1}
      assert StatusCheck.find_open(board, 7) == {7, 1}
    end

    @tag :setup_board_full
    test "returns nil if no open moves for a column", %{board: board} do
      assert StatusCheck.find_open(board, 1) == nil
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
