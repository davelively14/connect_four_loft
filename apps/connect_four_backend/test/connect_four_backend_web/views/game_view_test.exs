defmodule ConnectFourBackendWeb.GameViewTest do
  use ConnectFourBackendWeb.ConnCase, async: true
  alias ConnectFour.GameServer
  alias ConnectFourBackendWeb.GameView

  setup do
    GameServer.start_link(%{height: 6, width: 7})
    :ok
  end

  describe "state.json" do
    test "renders an appropriate state" do
      assert state = GameView.render("state.json", GameServer.get_state())

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
  end
end
