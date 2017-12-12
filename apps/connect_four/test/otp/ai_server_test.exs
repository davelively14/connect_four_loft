defmodule ConnectFour.AIServerTest do
  use ExUnit.Case
  alias ConnectFour.{AIServer, GameServer}

  setup do
    GameServer.start_link(%{height: 6, width: 7})
    AIServer.start_link()
    initial_ai_state = AIServer.get_state
    initial_game_state = GameServer.get_state
    {:ok, %{initial_game_state: initial_game_state, initial_ai_state: initial_ai_state}}
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
end
