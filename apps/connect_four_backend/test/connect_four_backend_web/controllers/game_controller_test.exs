defmodule ConnectFourBackendWeb.GameControllerTest do
  use ConnectFourBackendWeb.ConnCase

  describe "POST create" do
    test "with no parameters, starts a new game with default dimensions", %{conn: conn} do
      conn = post conn, game_path(conn, :create)
      assert state = json_response(conn, 200)

      assert state["height"] == 6
      assert state["width"] == 7
      assert state["board"]["free"] |> length == 6 * 7
    end

    test "with paramters, will start a new game with specified dimensions", %{conn: conn} do
      conn = post conn, game_path(conn, :create), height: 2, width: 10
      assert state = json_response(conn, 200)

      assert state["height"] == 2
      assert state["width"] == 10
      assert state["board"]["free"] |> length == 2 * 10
    end
  end
end
