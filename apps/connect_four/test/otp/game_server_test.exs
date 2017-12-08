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

      assert is_integer state.current_player
      assert is_integer state.height
      assert is_integer state.width
      assert !state.finished
    end
  end

  describe "drop_piece/1" do
    test "valid play records move" do
      assert :ok = GenServer.drop_piece(1)
      state = GameServer.get_state()

      refute MapSet.member?(state.board.free, {1,1})
      assert MapSet.member?(state.board.player_1, {1,1})
    end

    test "valid move alternates player" do
      state = GameServer.get_state()
      assert state.current_player == 1

      GenServer.drop_piece(1)
      state = GameServer.get_state()
      assert state.current_player == 2

      GenServer.drop_piece(1)
      state = GameServer.get_state()
      assert state.current_player == 1
    end

    test "invalid play not allowed" do
      for _ <- 1..6, do: GameServer.drop_piece(1)
      initial_state = GameServer.get_state()
      assert {:error, "Row is full"} == GameServer.drop_piece(1)

      end_state = GameServer.get_state()
      assert initial_state.current_player == end_state.current_player
    end
  end
end
