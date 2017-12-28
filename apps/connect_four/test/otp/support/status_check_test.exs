defmodule ConnectFour.StatusCheckTest do
  use ExUnit.Case
  alias ConnectFour.{GameServer, StatusCheck}

  setup context do
    GameServer.start_link()
    {:ok, game_id} = GameServer.new_game()

    cond do
      context[:setup_board_vert_block] -> setup_board_vert_block(game_id)
      context[:setup_board_vert_win] -> setup_board_vert_win(game_id)
      context[:setup_board_lat_block] -> setup_board_lat_block(game_id)
      context[:setup_board_lat_win] -> setup_board_lat_win(game_id)
      context[:setup_board_diag_back_block] -> setup_board_diag_back_block(game_id)
      context[:setup_board_diag_back_win] -> setup_board_diag_back_win(game_id)
      context[:setup_board_diag_fwd_block] -> setup_board_diag_fwd_block(game_id)
      context[:setup_board_diag_fwd_win] -> setup_board_diag_fwd_win(game_id)
      context[:setup_board_full] -> setup_board_full(game_id)
      true -> nil
    end

    game_state = %{board: board, avail_cols: avail_cols} = GameServer.get_game(game_id)

    {player, loc} =
      if game_state.last_play, do: game_state.last_play, else: {:player_1, nil}

    {:ok, %{game_state: game_state, board: board, player: player, loc: loc, avail_cols: avail_cols, game_id: game_id}}
  end

  describe "get_block_cols/1" do
    test "returns nil if new board or no threat to win", %{game_state: game_state} do
      refute StatusCheck.get_block_cols(game_state)
    end

    @tag :setup_board_vert_block
    test "returns correct column required for blocking vertically", %{game_state: game_state} do
      assert StatusCheck.get_block_cols(game_state) == 1
    end

    @tag :setup_board_lat_block
    test "returns multiple columns for blocking when multiple ways to win", %{game_state: game_state} do
      result = StatusCheck.get_block_cols(game_state)

      assert result == 2 || result == 6
    end

    @tag :setup_board_diag_back_block
    test "returns column for blocking a diagonal back", %{game_state: game_state} do
      assert StatusCheck.get_block_cols(game_state) == 1
    end

    @tag :setup_board_diag_fwd_block
    test "returns column for blocking a diagonal forward", %{game_state: game_state} do
      assert StatusCheck.get_block_cols(game_state) == 4
    end

    @tag :setup_board_full
    test "returns nil if board is full", %{game_state: game_state} do
      refute StatusCheck.get_block_cols(game_state)
    end
  end

  describe "get_win_col/1" do
    test "returns nil if no move to win", %{game_state: game_state} do
      refute StatusCheck.get_block_cols(game_state)
    end

    @tag :setup_board_vert_win
    test "returns column for winning when vertical win available", %{game_state: game_state} do
      assert StatusCheck.get_win_col(game_state) == 1
    end

    @tag :setup_board_lat_win
    test "returns column for winning when lateral win available", %{game_state: game_state} do
      resp = StatusCheck.get_win_col(game_state)

      assert resp == 2 || resp == 6
    end

    @tag :setup_board_diag_back_win
    test "returns column for winning when diagonal back win available", %{game_state: game_state} do
      assert StatusCheck.get_win_col(game_state) == 1
    end

    @tag :setup_board_diag_fwd_win
    test "returns column for winning when diagonal fwd win available", %{game_state: game_state} do
      assert StatusCheck.get_win_col(game_state) == 4
    end

    @tag :setup_board_full
    test "returns nil if board is full", %{game_state: game_state} do
      refute StatusCheck.get_win_col(game_state)
    end
  end

  describe "check_win_or_draw/3" do
    @tag :setup_board_vert_block
    test "returns player when a player's piece at loc would win vertically", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {1,4}) == player
    end

    @tag :setup_board_vert_block
    test "returns nil when a player's piece at loc would not win vertically", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {1,3}) == nil
    end

    @tag :setup_board_lat_block
    test "returns player when a player's piece at loc would win laterally", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {6,1}) == player
      assert StatusCheck.check_win_or_draw(board, player, {2,1}) == player
    end

    @tag :setup_board_lat_block
    test "returns nil when a player's piece at loc would not win laterally", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {1,1}) == nil
      assert StatusCheck.check_win_or_draw(board, player, {7,1}) == nil
      assert StatusCheck.check_win_or_draw(board, player, {3,1}) == nil
    end

    @tag :setup_board_diag_back_block
    test "returns player when a player's piece at loc would win diagonally backward", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {1,4}) == player
    end

    @tag :setup_board_diag_back_block
    test "returns nil when a player's piece at loc would not win diagonally backward", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {2,4}) == nil
      assert StatusCheck.check_win_or_draw(board, player, {3,3}) == nil
    end

    @tag :setup_board_diag_fwd_block
    test "returns player when a player's piece at loc would win diagonally forward", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {4,4}) == player
    end

    @tag :setup_board_diag_fwd_block
    test "returns nil when a player's piece at loc would not win diagonally forward", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {3,4}) == nil
    end

    @tag :setup_board_full
    test "returns :draw when a player's piece at loc would end in a draw", %{board: board, player: player} do
      assert StatusCheck.check_win_or_draw(board, player, {3,4}) == :draw
    end
  end

  describe "check_lateral/2" do
    @describetag :setup_board_lat_block

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

  describe "lateral_chain_length/2" do
    @describetag :setup_board_lat_block

    test "returns correct number for a given play with all right", %{board: board} do
      assert StatusCheck.lateral_chain_length(board[:player_1], {2, 1}) == 4
    end

    test "returns correct number for a sandwich play", %{game_id: game_id} do
      GameServer.drop_piece(game_id, 3)
      GameServer.drop_piece(game_id, 1)
      game_state = GameServer.get_game(game_id)

      assert StatusCheck.lateral_chain_length(game_state.board[:player_1], {2, 1}) == 5
    end

    test "returns correct number for a given play with all left", %{board: board} do
      assert StatusCheck.lateral_chain_length(board[:player_1], {6, 1}) == 4
    end
  end

  describe "check_vertical/2" do
    @describetag :setup_board_vert_block

    test "returns true when a player's piece at loc would win vertically", %{board: board, player: player} do
      assert StatusCheck.check_vertical(board[player], {1,4})
    end

    test "returns false when a player's piece at loc would not win laterally", %{board: board, player: player} do
      refute StatusCheck.check_vertical(board[player], {1,3})
      refute StatusCheck.check_vertical(board[player], {2,1})
      refute StatusCheck.check_vertical(board[player], {6,6})
    end

    test "returns streak instead of true/false when a non-integer is passed", %{board: board, player: player} do
      assert StatusCheck.check_vertical(board[player], {1,4}, :max) == 4
    end
  end

  describe "check_diag_back/2" do
    @describetag :setup_board_diag_back_block

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
    @describetag :setup_board_diag_fwd_block

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

    @tag :setup_board_vert_block
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

  defp setup_board_vert_block(game_id) do
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
  end

  defp setup_board_vert_win(game_id) do
    setup_board_vert_block(game_id)
    GameServer.drop_piece(game_id, 2)
  end

  defp setup_board_lat_block(game_id) do
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 5)
  end

  defp setup_board_lat_win(game_id) do
    setup_board_lat_block(game_id)
    GameServer.drop_piece(game_id, 5)
  end

  defp setup_board_diag_back_block(game_id) do
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 7)
    GameServer.drop_piece(game_id, 3)
  end

  defp setup_board_diag_back_win(game_id) do
    setup_board_diag_back_block(game_id)
    GameServer.drop_piece(game_id, 7)
  end

  defp setup_board_diag_fwd_block(game_id) do
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 7)
    GameServer.drop_piece(game_id, 2)
  end

  def setup_board_diag_fwd_win(game_id) do
    setup_board_diag_fwd_block(game_id)
    GameServer.drop_piece(game_id, 7)
  end

  defp setup_board_full(game_id) do
    for outer <- 0..1 do
      for x <- 1..3 do
        for _ <- 0..4 do
          GameServer.drop_piece(game_id, x + outer * 3)
        end
      end
      for x <- 1..3 do
        GameServer.drop_piece(game_id, x + outer * 3)
      end
    end
    for _ <- 1..6 do
      GameServer.drop_piece(game_id, 7)
    end
  end
end
