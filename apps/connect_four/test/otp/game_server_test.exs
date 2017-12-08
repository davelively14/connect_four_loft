defmodule ConnectFour.GameServerTest do
  use ExUnit.Case
  alias ConnectFour.GameServer

  setup do
    ConnectFour.start(nil, %{height: 6, width: 7})
    :ok
  end

  describe "get_state/0" do
    test "returns state with default params" do
      state = GameServer.get_state()
      assert is_map state.board
      assert 7 * 6 == MapSet.size state.board.free
      assert 0 == MapSet.size state.board.player_1
      assert 0 == MapSet.size state.board.player_2

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
      assert {:error, "Row is full"} == GameServer.drop_piece(1)

      end_state = GameServer.get_state()
      assert initial_state.current_player == end_state.current_player
    end

    test "returns winner when game is won" do
      assert {:ok, "player_1 wins!"} == win_game()
    end

    test "further attempts to play will result in error when game is already won" do
      win_game()
      assert {:error, "player_1 already won the game."} == GameServer.drop_piece(2)
    end

    test "reports when draw occurs" do
      assert {:ok, "The game ended in a draw."} == fill_board()
    end

    test "further attempts to play will result in error when game is already in draw" do
      fill_board()
      assert {:error, "The game ended in a draw."} == GameServer.drop_piece(1)
    end
  end

  #####################
  # Private Functions #
  #####################

  defp fill_board do
    for _ <- 1..6 do
      for x <- 1..7 do
        GameServer.drop_piece(x)
      end
    end
    |> List.flatten()
    |> List.last()
  end

  defp win_game do
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
  end
end
