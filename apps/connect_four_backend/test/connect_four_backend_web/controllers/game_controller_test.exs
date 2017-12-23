defmodule ConnectFourBackendWeb.GameControllerTest do
  use ConnectFourBackendWeb.ConnCase
  alias ConnectFour.GameServer

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

  describe "GET show" do
    setup :game_started

    test "with valid game_id, returns a game state", %{conn: conn, game_id: game_id} do
      conn = get conn, game_path(conn, :show, game_id)
      assert state = json_response(conn, 200)

      assert state["id"] == game_id
      assert state["height"] == 6
      assert state["width"] == 7
      assert state["board"]["free"] |> length == 6 * 7
    end

    test "with invalid format, returns invalid parameter error", %{conn: conn} do
      conn = get conn, game_path(conn, :show, -1)
      assert %{"error" => "Invalid format for id"} == json_response(conn, 422)
    end

    test "with invalid game_id, returns appropriate error", %{conn: conn} do
      conn = get conn, game_path(conn, :show, 240)
      assert %{"error" => "Game does not exist"} == json_response(conn, 422)
    end
  end

  describe "PUT update, no difficulty" do
    setup :game_started

    test "with valid game_id and column, returns an updated game state", %{conn: conn, game_id: game_id} do
      conn = put conn, game_path(conn, :update, game_id), col: 1
      assert resp = json_response(conn, 200)

      assert resp["id"] == game_id
      assert resp["last_play"] == ["player_1", [1, 1]]
    end

    test "handles win condition", %{conn: conn, game_id: game_id} do
      setup_win(game_id)
      conn = put conn, game_path(conn, :update, game_id), col: 1
      assert resp = json_response(conn, 200)

      assert resp["finished"]
    end

    test "handles attempts when game is already over", %{conn: conn, game_id: game_id} do
      game_won(game_id)
      conn = put conn, game_path(conn, :update, game_id), col: 1
      assert %{"error" => "player_1 already won the game."} == json_response(conn, 422)
    end

    test "with invalid game_id, returns error", %{conn: conn} do
      conn = put conn, game_path(conn, :update, 9999), col: 1
      assert %{"error" => "Game does not exist"} == json_response(conn, 422)
    end

    test "with invalid column integer, returns error", %{conn: conn, game_id: game_id} do
      conn = put conn, game_path(conn, :update, game_id), col: 13
      assert %{"error" => "Invalid column"} == json_response(conn, 422)
    end

    test "with invalid column format, returns error", %{conn: conn, game_id: game_id} do
      conn = put conn, game_path(conn, :update, game_id), col: "hello"
      assert %{"error" => "Invalid parameters"} == json_response(conn, 422)
    end
  end

  describe "PUT update, with difficulty" do
    setup :game_started

    test "with valid game_id, column, and difficulty cpu will make a move", %{conn: conn, game_id: game_id} do
      conn = put conn, game_path(conn, :update, game_id), col: 1, difficulty: "easy"
      assert resp = json_response(conn, 200)

      assert resp["id"] == game_id
      assert resp["board"]["player_1"] |> length == 1
      assert resp["board"]["player_2"] |> length == 1
    end

    test "with valid game_id and column, and invalid difficulty, CPU does not move", %{conn: conn, game_id: game_id} do
      conn = put conn, game_path(conn, :update, game_id), col: 1, difficulty: "hotly"
      assert resp = json_response(conn, 200)

      assert resp["id"] == game_id
      assert resp["board"]["player_1"] |> length == 1
      assert resp["board"]["player_2"] |> length == 0
    end
  end

  ###################
  # Setup Functions #
  ###################

  defp game_started(_context) do
    GameServer.start_link()
    {:ok, game_id} = GameServer.new_game()

    {:ok, game_id: game_id}
  end

  defp game_started_easy(_context) do
    GameServer.start_link()
    {:ok, game_id} = GameServer.new_game(:easy)

    {:ok, game_id: game_id}
  end

  #####################
  # Private Functions #
  #####################

  defp setup_win(game_id) do
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 2)
  end

  defp game_won(game_id) do
    setup_win(game_id)
    GameServer.drop_piece(game_id, 1)
  end
end
