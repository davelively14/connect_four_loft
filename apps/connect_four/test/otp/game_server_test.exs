defmodule ConnectFour.GameServerTest do
  use ExUnit.Case
  alias ConnectFour.GameServer

  setup do
    GameServer.start_link(%{height: 6, width: 7})
    initial_state = GameServer.get_state
    {:ok, %{initial_state: initial_state}}
  end

  describe "get_state/0" do
    test "returns state with default params" do
      state = GameServer.get_state()
      assert is_map state.board
      assert 7 * 6 == MapSet.size state.board.free
      assert 0 == MapSet.size state.board.player_1
      assert 0 == MapSet.size state.board.player_2
      assert state.avail_cols == [1,2,3,4,5,6,7]
      assert state.last_play == nil

      assert is_atom state.current_player
      assert is_integer state.height
      assert is_integer state.width
      assert !state.finished
    end
  end

  describe "drop_piece/1" do
    test "valid play records move" do
      assert :ok = GameServer.drop_piece(1)
      state = GameServer.get_state()
      refute MapSet.member?(state.board.free, {1,1})
      assert MapSet.member?(state.board.player_1, {1,1})
    end

    test "valid move alternates player" do
      state = GameServer.get_state()
      assert state.current_player == :player_1

      GameServer.drop_piece(1)
      state = GameServer.get_state()
      assert state.current_player == :player_2

      GameServer.drop_piece(1)
      state = GameServer.get_state()
      assert state.current_player == :player_1
    end

    test "invalid play returns error" do
      for _ <- 1..6, do: GameServer.drop_piece(1)
      initial_state = GameServer.get_state()
      assert {:error, "Column 1 is full. Chose another column."} == GameServer.drop_piece(1)

      end_state = GameServer.get_state()
      assert initial_state.current_player == end_state.current_player
    end

    test "returns winner when game is won laterally" do
      assert {:ok, :player_1} == win_game_lateral()
    end

    test "returns winner when game is won vertically" do
      assert {:ok, :player_1} == win_game_vertical()
    end

    test "returns winner when game is won diagonally - blackslash" do
      assert {:ok, :player_1} == win_game_diag_back()
    end

    test "returns winner when game is won diagonally - forwardslash" do
      assert {:ok, :player_1} == win_game_diag_fwd()
    end

    test "further attempts to play will result in error when game is already won" do
      win_game_lateral()
      assert {:error, "player_1 already won the game."} == GameServer.drop_piece(2)
    end

    test "reports when draw occurs" do
      assert {:ok, :draw} == fill_board()
    end

    test "further attempts to play will result in error when game is already in draw" do
      fill_board()
      assert {:error, "The game ended in a draw."} == GameServer.drop_piece(1)
    end

    test "filling a row will result in dropping that row from avail_cols" do
      GameServer.drop_piece(1)
      GameServer.drop_piece(1)
      GameServer.drop_piece(1)
      GameServer.drop_piece(1)
      GameServer.drop_piece(1)
      assert GameServer.get_state |> Map.get(:avail_cols) == [1,2,3,4,5,6,7]
      GameServer.drop_piece(1)
      assert GameServer.get_state |> Map.get(:avail_cols) == [2,3,4,5,6,7]
    end

    test "records last play" do
      assert GameServer.get_state |> Map.get(:last_play) == nil
      GameServer.drop_piece(1)
      assert GameServer.get_state |> Map.get(:last_play) == {:player_1, {1,1}}
    end
  end

  describe "check_lateral/2" do
    test "returns true if win laterally" do
      loc = {3,1}
      assert GameServer.check_lateral(win_lateral_board(loc), loc)
    end

    test "returns false if no win laterally" do
      loc = {3,1}
      refute GameServer.check_lateral(no_win_lateral_board(loc), loc)
    end
  end

  describe "check_vertical/2" do
    test "returns true if win vertically" do
      loc = {1,4}
      assert GameServer.check_vertical(win_vertical_board(loc), loc)
    end

    test "returns false if no win vertically" do
      loc = {1,3}
      refute GameServer.check_vertical(no_win_vertical_board(loc), loc)
    end
  end

  describe "check_diag_back/2" do
    test "returns true if win backslash diagonally" do
      loc = {3,3}
      assert GameServer.check_diag_back(win_diag_back_board(loc), loc)
    end

    test "returns false if no win backslash diagonally" do
      loc = {3,3}
      refute GameServer.check_diag_back(no_win_diag_back_board(loc), loc)
    end
  end

  describe "check_diag_fwd/2" do
    test "returns true if win forwardslash diagonally" do
      loc = {3,3}
      assert GameServer.check_diag_fwd(win_diag_fwd_board(loc), loc)
    end

    test "returns false if no win forwardslash diagonally" do
      loc = {3,3}
      refute GameServer.check_diag_fwd(no_win_diag_fwd_board(loc), loc)
    end
  end

  describe "reset_game/0" do
    test "resets a game to original parameters with game in progress", %{initial_state: initial_state} do
      middle_of_game()
      current_state = GameServer.get_state()
      refute current_state.finished
      refute initial_state == current_state

      assert :ok == GameServer.reset_game()

      reset_state = GameServer.get_state()
      assert reset_state == initial_state
    end

    test "resets a game to original parameters when game is won", %{initial_state: initial_state} do
      win_game_vertical()
      current_state = GameServer.get_state()
      assert current_state.finished == :player_1
      refute initial_state == current_state

      assert :ok == GameServer.reset_game()

      reset_state = GameServer.get_state()
      assert reset_state == initial_state
    end

    test "resets a game to original parameters when game is a draw", %{initial_state: initial_state} do
      fill_board()
      current_state = GameServer.get_state()
      assert current_state.finished == :draw
      refute initial_state == current_state

      assert :ok == GameServer.reset_game()

      reset_state = GameServer.get_state()
      assert reset_state == initial_state
    end
  end

  describe "current_player/0" do
    test "returns the current player" do
      assert GameServer.current_player == :player_1
      GameServer.drop_piece(1)
      assert GameServer.current_player == :player_2
    end
  end

  describe "new_game/2" do
    test "creates a new game with height 5 and width 2", %{initial_state: initial_state} do
      middle_of_game()
      GameServer.new_game(5, 2)

      new_state = GameServer.get_state()

      refute new_state == initial_state
      assert new_state.height == 5
      assert new_state.width == 2
      assert new_state.board.free |> MapSet.size == 5 * 2
    end
  end

  #####################
  # Private Functions #
  #####################

  defp fill_board do
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

  defp win_game_vertical do
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
  end

  defp win_game_lateral do
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(3)
    GameServer.drop_piece(3)
    GameServer.drop_piece(4)
  end

  defp win_game_diag_back do
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(3)
    GameServer.drop_piece(3)
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(4)
  end

  defp win_game_diag_fwd do
    GameServer.drop_piece(3)
    GameServer.drop_piece(3)
    GameServer.drop_piece(3)
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(4)
    GameServer.drop_piece(4)
    GameServer.drop_piece(4)
    GameServer.drop_piece(4)
    GameServer.drop_piece(4)
    GameServer.drop_piece(1)
  end

  defp middle_of_game do
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
  end

  defp win_lateral_board({x, y}) do
    MapSet.new()
    |> MapSet.put({x, y})
    |> MapSet.put({x + 1, y})
    |> MapSet.put({x + 2, y})
    |> MapSet.put({x - 1, y})
  end

  defp no_win_lateral_board({x, y}) do
    MapSet.new()
    |> MapSet.put({x, y})
    |> MapSet.put({x + 1, y})
    |> MapSet.put({x + 2, y})
  end

  defp win_vertical_board({x, y}) do
    MapSet.new()
    |> MapSet.put({x, y})
    |> MapSet.put({x, y - 1})
    |> MapSet.put({x, y - 2})
    |> MapSet.put({x, y - 3})
  end

  defp no_win_vertical_board({x, y}) do
    MapSet.new()
    |> MapSet.put({x, y})
    |> MapSet.put({x, y - 1})
  end

  defp win_diag_back_board({x, y}) do
    MapSet.new()
    |> MapSet.put({x, y})
    |> MapSet.put({x - 1, y + 1})
    |> MapSet.put({x - 2, y + 2})
    |> MapSet.put({x + 1, y - 1})
  end

  defp no_win_diag_back_board({x, y}) do
    MapSet.new()
    |> MapSet.put({x, y})
    |> MapSet.put({x - 1, y + 1})
    |> MapSet.put({x + 1, y - 1})
  end

  defp win_diag_fwd_board({x, y}) do
    MapSet.new()
    |> MapSet.put({x, y})
    |> MapSet.put({x + 1, y + 1})
    |> MapSet.put({x + 2, y + 2})
    |> MapSet.put({x - 1, y - 1})
  end

  defp no_win_diag_fwd_board({x, y}) do
    MapSet.new()
    |> MapSet.put({x, y})
    |> MapSet.put({x + 1, y + 1})
    |> MapSet.put({x - 1, y - 1})
  end
end
