defmodule ConnectFour.AIServerTest do
  use ExUnit.Case
  alias ConnectFour.{AIServer, GameServer}

  setup do
    GameServer.start_link(%{height: 6, width: 7})
    AIServer.start_link()
    initial_ai_state = AIServer.get_state
    {:ok, %{initial_ai_state: initial_ai_state}}
  end

  describe "get_state/0" do
    test "returns the default state" do
      assert AIServer.get_state == %{
        initial_difficulty: :easy,
        difficulty: :easy
      }
    end
  end

  describe "set_difficulty/1" do
    test "changes the difficulty from default to :hard" do
      assert AIServer.get_state() |> Map.get(:difficulty) == :easy

      AIServer.set_difficulty(:hard)

      assert AIServer.get_state() |> Map.get(:difficulty) == :hard
    end

    test "cannot change the difficulty to unexpected value" do
      assert AIServer.get_state |> Map.get(:difficulty) == :easy
      assert AIServer.set_difficulty(:even_harder) == :error
      assert AIServer.get_state |> Map.get(:difficulty) == :easy
    end
  end

  describe "reset_ai/0" do
    test "resets the ai to the default", %{initial_ai_state: initial_ai_state} do
      AIServer.set_difficulty(:hard)
      refute AIServer.get_state == initial_ai_state
      AIServer.reset_ai()
      assert AIServer.get_state == initial_ai_state
    end
  end

  # describe "make_move: easy level" do
  #   test "makes a move when passed the state of a game" do
  #     initial_state = GameServer.get_state()
  #     AIServer.make_move()
  #     new_state = GameServer.get_state()
  #
  #     refute initial_state == new_state
  #     assert initial_state.player_1 |> MapSet.size == 0
  #     assert new_state.player_1 |> MapSet.size == 1
  #   end
  # end

  describe "block_opponent?/1" do
    test "will block opponent about to win vertically" do
      setup_vert_3()
      assert AIServer.block_opponent?(GameServer.get_state()) == 1
    end

    test "will block opponenet if about to win laterally" do
      setup_lat_3()
      assert AIServer.block_opponent?(GameServer.get_state()) == 3
    end
  end

  #####################
  # Private Functions #
  #####################

  defp setup_vert_3 do
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(1)
  end

  defp setup_lat_3 do
    GameServer.drop_piece(1)
    GameServer.drop_piece(1)
    GameServer.drop_piece(2)
    GameServer.drop_piece(2)
    GameServer.drop_piece(3)
  end
end
