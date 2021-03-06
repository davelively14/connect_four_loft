defmodule ConnectFourBackendWeb.GameViewTest do
  use ConnectFourBackendWeb.ConnCase, async: true
  alias ConnectFour.GameServer
  alias ConnectFourBackendWeb.GameView

  setup do
    GameServer.start_link()
    {:ok, game_id} = GameServer.new_game()
    {:ok, game_id: game_id}
  end

  describe "state.json" do
    test "renders an appropriate state", %{game_id: game_id} do
      assert state = GameView.render("state.json", %{game_state: GameServer.get_game(game_id), game_id: game_id})

      assert state.height == 6
      assert state.width == 7

      assert board = state.board
      assert is_list board.free
      assert board.free |> length == 6 * 7
      assert is_list board.player_1
      assert is_list board.player_2

      assert state.current_player == :player_1
      refute state.finished
      refute state.last_play
    end

    test "renders last_play appropriately", %{game_id: game_id} do
      assert state = GameView.render("state.json", %{game_state: GameServer.get_game(game_id), game_id: game_id})
      assert state.last_play == nil

      GameServer.drop_piece(game_id, 1)

      assert state = GameView.render("state.json", %{game_state: GameServer.get_game(game_id), game_id: game_id})
      assert state.last_play == [:player_1, [1, 1]]
    end
  end

  describe "error.json" do
    test "renders appropriate message" do
      assert %{error: "An error"} == GameView.render("error.json", %{error: "An error"})
    end
  end
end
