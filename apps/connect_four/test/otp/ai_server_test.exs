defmodule ConnectFour.AIServerTest do
  use ExUnit.Case
  alias ConnectFour.{AIServer, GameServer}

  setup do
    GameServer.start_link(%{height: 6, width: 7})
    AIServer.start_link()
    initial_AI_state = AIServer.get_state
    initial_game_state = GameServer.get_state
    {:ok, %{initial_game_state: initial_game_state, initial_AI_state: initial_AI_state}}
  end

  describe "get_state/0" do
    test "returns the default state" do
      assert AIServer.get_state == %{
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
end
