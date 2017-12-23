defmodule ConnectFourBackendWeb.GameControllerTest do
  use ConnectFourBackendWeb.ConnCase

  describe "POST create" do
    test "with no parameters, starts a new game with default dimensions", %{conn: conn} do
      conn = post conn, game_path(conn, :create)
      assert state = json_response(conn, 201)

      assert state["height"] == 6
      assert state["width"] == 7
      assert state["board"]["free"] |> length == 6 * 7
    end

    test "with parameters, will start a new game with specified dimensions", %{conn: conn} do
      conn = post conn, game_path(conn, :create), height: 2, width: 10
      assert state = json_response(conn, 201)

      assert state["height"] == 2
      assert state["width"] == 10
      assert state["board"]["free"] |> length == 2 * 10
    end

    test "with incorrect parameters, will start a game with default parameters", %{conn: conn} do
      conn = post conn, game_path(conn, :create), height: "hello", width: "world"
      assert %{"error" => "Invalid parameters"} == json_response(conn, 422)
    end

    test "with negative height, will start a game with default parameters", %{conn: conn} do
      conn = post conn, game_path(conn, :create), height: "-4", width: "5"
      assert %{"error" => "Invalid parameters"} == json_response(conn, 422)
    end

    test "with negative width, will start a game with default parameters", %{conn: conn} do
      conn = post conn, game_path(conn, :create), height: "4", width: "-5"
      assert %{"error" => "Invalid parameters"} == json_response(conn, 422)
    end
  end
end
