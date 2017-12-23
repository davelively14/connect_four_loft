defmodule ConnectFour.GameServerTest do
  use ExUnit.Case
  alias ConnectFour.GameServer

  setup context do
    GameServer.start_link()
    initial_state = GameServer.get_state()

    cond do
      context[:start_new_game] ->
        {:ok, game_id} = GameServer.new_game()
        {:ok, %{initial_state: initial_state, game_id: game_id}}
      true ->
        {:ok, %{initial_state: initial_state}}
    end
  end

  describe "new_game/0" do
    test "returns the game id", %{initial_state: initial_state} do
      {:ok, game_id} = GameServer.new_game()
      assert game_id == initial_state.next_id
    end

    test "adds a new game with default parameters" do
      {:ok, game_id} = GameServer.new_game()

      new_game = GameServer.get_game(game_id)

      assert is_map new_game.board
      assert 7 * 6 == MapSet.size new_game.board.free
      assert 0 == MapSet.size new_game.board.player_1
      assert 0 == MapSet.size new_game.board.player_2
      assert new_game.avail_cols == [1,2,3,4,5,6,7]
      assert new_game.last_play == nil

      assert is_atom new_game.current_player
      assert is_integer new_game.height
      assert is_integer new_game.width
      assert !new_game.finished
    end

    test "advances next_id", %{initial_state: initial_state} do
      GameServer.new_game()
      assert GameServer.get_state() |> Map.get(:next_id) == initial_state.next_id + 1
    end

    test "creates a new game with a different id" do
      {:ok, initial_game_id} = GameServer.new_game()
      GameServer.drop_piece(initial_game_id, 1)
      {:ok, new_game_id} = GameServer.new_game()
      refute GameServer.get_game(initial_game_id) == GameServer.get_game(new_game_id)
    end
  end

  describe "new_game/3" do
    @tag :start_new_game
    test "resets the game and sets height to 5 and width to 2", %{game_id: game_id} do
      initial_state = GameServer.get_game(game_id)
      middle_of_game(game_id)
      GameServer.new_game(game_id, 5, 2)

      new_state = GameServer.get_game(game_id)

      refute new_state == initial_state
      assert new_state.height == 5
      assert new_state.width == 2
      assert new_state.board.free |> MapSet.size == 5 * 2
    end

    test "returns error if game does not exist" do
      assert {:error, _} = GameServer.new_game(-1, 5, 2)
    end
  end

  describe "get_state/0" do
    test "returns state with default params" do
      state = GameServer.get_state()
      assert is_integer(state.next_id)
      assert state.ets == :games
    end
  end

  describe "get_game/1" do
    @describetag :start_new_game
    test "returns a game", %{game_id: game_id} do
      assert game = GameServer.get_game(game_id)
      assert game.board.free |> MapSet.size == 7 * 6
    end

    test "returns error if game does not exist" do
      assert {:error, _} = GameServer.get_game(-1)
    end
  end

  describe "drop_piece/1" do
    @describetag :start_new_game

    test "valid play records move", %{game_id: game_id} do
      assert :ok = GameServer.drop_piece(game_id, 1)
      game = GameServer.get_game(game_id)
      refute MapSet.member?(game.board.free, {1,1})
      assert MapSet.member?(game.board.player_1, {1,1})
    end

    test "invalid game_id results in error" do
      assert {:error, _} = GameServer.drop_piece(-1, 1)
    end

    test "valid move alternates player", %{game_id: game_id} do
      game = GameServer.get_game(game_id)
      assert game.current_player == :player_1

      GameServer.drop_piece(game_id, 1)
      game = GameServer.get_game(game_id)
      assert game.current_player == :player_2

      GameServer.drop_piece(game_id, 1)
      game = GameServer.get_game(game_id)
      assert game.current_player == :player_1
    end

    test "invalid play returns error", %{game_id: game_id} do
      for _ <- 1..6, do: GameServer.drop_piece(game_id, 1)
      initial_game_state = GameServer.get_game(game_id)
      assert {:error, "Column 1 is full. Chose another column."} == GameServer.drop_piece(game_id, 1)

      end_game_state = GameServer.get_game(game_id)
      assert initial_game_state.current_player == end_game_state.current_player
    end

    test "returns winner when game is won laterally", %{game_id: game_id} do
      assert {:ok, :player_1} == win_game_lateral(game_id)
    end

    test "returns winner when game is won vertically", %{game_id: game_id} do
      assert {:ok, :player_1} == win_game_vertical(game_id)
    end

    test "returns winner when game is won diagonally - blackslash", %{game_id: game_id} do
      assert {:ok, :player_1} == win_game_diag_back(game_id)
    end

    test "returns winner when game is won diagonally - forwardslash", %{game_id: game_id} do
      assert {:ok, :player_1} == win_game_diag_fwd(game_id)
    end

    test "further attempts to play will result in error when game is already won", %{game_id: game_id} do
      win_game_lateral(game_id)
      assert {:error, "player_1 already won the game."} == GameServer.drop_piece(game_id, 2)
    end

    test "reports when draw occurs", %{game_id: game_id} do
      assert {:ok, :draw} == fill_board(game_id)
    end

    test "further attempts to play will result in error when game is already in draw", %{game_id: game_id} do
      fill_board(game_id)
      assert {:error, "The game ended in a draw."} == GameServer.drop_piece(game_id, 1)
    end

    test "filling a row will result in dropping that row from avail_cols", %{game_id: game_id} do
      GameServer.drop_piece(game_id, 1)
      GameServer.drop_piece(game_id, 1)
      GameServer.drop_piece(game_id, 1)
      GameServer.drop_piece(game_id, 1)
      GameServer.drop_piece(game_id, 1)
      assert GameServer.get_game(game_id) |> Map.get(:avail_cols) == [1,2,3,4,5,6,7]
      GameServer.drop_piece(game_id, 1)
      assert GameServer.get_game(game_id) |> Map.get(:avail_cols) == [2,3,4,5,6,7]
    end

    test "records last play", %{game_id: game_id} do
      assert GameServer.get_game(game_id) |> Map.get(:last_play) == nil
      GameServer.drop_piece(game_id, 1)
      assert GameServer.get_game(game_id) |> Map.get(:last_play) == {:player_1, {1,1}}
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

  describe "reset_game/1" do
    @describetag :start_new_game

    test "resets a game to original parameters with game in progress", %{game_id: game_id} do
      initial_state = GameServer.get_game(game_id)
      middle_of_game(game_id)
      current_state = GameServer.get_game(game_id)
      refute current_state.finished
      refute initial_state == current_state

      assert :ok == GameServer.reset_game(game_id)

      reset_state = GameServer.get_game(game_id)
      assert reset_state == initial_state
    end

    test "invalid game_id results in error" do
      assert {:error, _} = GameServer.reset_game(-1)
    end

    test "resets a game to original parameters when game is won", %{game_id: game_id} do
      initial_state = GameServer.get_game(game_id)
      win_game_vertical(game_id)
      current_state = GameServer.get_game(game_id)
      assert current_state.finished == :player_1
      refute initial_state == current_state

      assert :ok == GameServer.reset_game(game_id)

      reset_state = GameServer.get_game(game_id)
      assert reset_state == initial_state
    end

    test "resets a game to original parameters when game is a draw", %{game_id: game_id} do
      initial_state = GameServer.get_game(game_id)
      fill_board(game_id)
      current_state = GameServer.get_game(game_id)
      assert current_state.finished == :draw
      refute initial_state == current_state

      assert :ok == GameServer.reset_game(game_id)

      reset_state = GameServer.get_game(game_id)
      assert reset_state == initial_state
    end
  end

  describe "current_player/1" do
    @tag :start_new_game
    test "returns the current player", %{game_id: game_id} do
      assert GameServer.current_player(game_id) == :player_1
      GameServer.drop_piece(game_id, 1)
      assert GameServer.current_player(game_id) == :player_2
    end

    test "invalid game_id results in error" do
      assert {:error, _} = GameServer.current_player(-1)
    end
  end

  #####################
  # Private Functions #
  #####################

  defp fill_board(game_id) do
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
    |> List.flatten()
    |> List.last()
  end

  defp win_game_vertical(game_id) do
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
  end

  defp win_game_lateral(game_id) do
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 4)
  end

  defp win_game_diag_back(game_id) do
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 4)
  end

  defp win_game_diag_fwd(game_id) do
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 3)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 4)
    GameServer.drop_piece(game_id, 1)
  end

  defp middle_of_game(game_id) do
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
