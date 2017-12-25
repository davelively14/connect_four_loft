defmodule ConnectFourBackendWeb.GameControllerTest do
  use ConnectFourBackendWeb.ConnCase
  alias ConnectFour.GameServer

  describe "POST create" do
    setup :game_started

    test "with no parameters, starts a new game with default dimensions", %{conn: conn} do
      conn = post conn, game_path(conn, :create)
      assert state = json_response(conn, 201)

      assert state["height"] == 6
      assert state["width"] == 7
      assert state["board"]["free"] |> length == 6 * 7
    end

    test "with height and width parameters, will start a new game with specified dimensions", %{conn: conn} do
      conn = post conn, game_path(conn, :create), height: 2, width: 10
      assert state = json_response(conn, 201)

      assert state["height"] == 2
      assert state["width"] == 10
      assert state["board"]["free"] |> length == 2 * 10
    end

    test "with game_id, will start a new game for same id", %{conn: conn, game_id: game_id} do
      conn = post conn, game_path(conn, :create), game_id: game_id
      assert state = json_response(conn, 201)

      assert state["id"] == game_id
    end

    test "returns error with game_id for game that does not exist", %{conn: conn} do
      conn = post conn, game_path(conn, :create), game_id: 999
      assert %{"error" => "Game does not exist"} == json_response(conn, 422)
    end

    test "can set difficulty", %{conn: conn} do
      conn = post conn, game_path(conn, :create), difficulty: "easy"
      assert state = json_response(conn, 201)

      assert state["difficulty"] == "easy"
    end

    test "cannot set unaccepted difficulty", %{conn: conn} do
      conn = post conn, game_path(conn, :create), difficulty: "twitter_hard"
      assert %{"error" => "Invalid parameters"} == json_response(conn, 422)
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

  describe "PATCH update, two player game" do
    setup :game_started

    test "with valid game_id and column, returns an updated game state", %{conn: conn, game_id: game_id} do
      conn = patch conn, game_path(conn, :update, game_id), col: 1
      assert resp = json_response(conn, 200)

      assert resp["id"] == game_id
      assert resp["last_play"] == ["player_1", [1, 1]]
    end

    test "handles win condition", %{conn: conn, game_id: game_id} do
      setup_win(game_id)
      conn = patch conn, game_path(conn, :update, game_id), col: 1
      assert resp = json_response(conn, 200)

      assert resp["finished"]
    end

    test "handles draw condition", %{conn: conn, game_id: game_id} do
      setup_draw(game_id)
      conn = patch conn, game_path(conn, :update, game_id), col: 7
      assert resp = json_response(conn, 200)

      assert "draw" = resp["finished"]
    end

    test "handles attempts when game is already over", %{conn: conn, game_id: game_id} do
      game_won(game_id)
      conn = patch conn, game_path(conn, :update, game_id), col: 1
      assert %{"error" => "player_1 already won the game."} == json_response(conn, 422)
    end

    test "with invalid game_id, returns error", %{conn: conn} do
      conn = patch conn, game_path(conn, :update, 9999), col: 1
      assert %{"error" => "Game does not exist"} == json_response(conn, 422)
    end

    test "with invalid column integer, returns error", %{conn: conn, game_id: game_id} do
      conn = patch conn, game_path(conn, :update, game_id), col: 13
      assert %{"error" => "Invalid column"} == json_response(conn, 422)
    end

    test "with invalid column format, returns error", %{conn: conn, game_id: game_id} do
      conn = patch conn, game_path(conn, :update, game_id), col: "hello"
      assert %{"error" => "Invalid parameters"} == json_response(conn, 422)
    end

    test "returns error if a full column is selected", %{conn: conn, game_id: game_id} do
      col_1_full(game_id)
      conn = patch conn, game_path(conn, :update, game_id), col: 1
      assert %{"error" => "Column 1 is full. Choose another column."} == json_response(conn, 422)
    end
  end

  describe "PATCH update, cpu difficulty" do
    setup :game_started_easy

    test "with valid column, CPU moves as well", %{conn: conn, game_id: game_id} do
      conn = patch conn, game_path(conn, :update, game_id), col: 1
      assert resp = json_response(conn, 200)

      assert ["player_2", [_, _]] = resp["last_play"]
      assert resp["board"]["player_1"] |> length == 1
      assert resp["board"]["player_2"] |> length == 1
    end
  end

  describe "PUT reset" do
    setup :game_started_easy

    test "with valid id, will reset game", %{conn: conn, game_id: game_id, initial_game_state: initial_game_state} do
      setup_win(game_id)
      conn = put conn, game_path(conn, :reset, game_id)
      assert resp = json_response(conn, 200)
      initial_state = ConnectFourBackendWeb.GameView.render("state.json", %{game_state: initial_game_state, game_id: game_id})

      assert resp["board"]["free"] == initial_state.board.free
    end

    test "with invalid id, will return error", %{conn: conn, game_id: game_id} do
      setup_win(game_id)
      conn = put conn, game_path(conn, :reset, 9999)
      assert %{"error" => "Game does not exist"} == json_response(conn, 422)
    end

    test "with negative integer, will return invalid parameters error", %{conn: conn, game_id: game_id} do
      setup_win(game_id)
      conn = put conn, game_path(conn, :reset, -1)
      assert %{"error" => "Invalid parameters"} == json_response(conn, 422)
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
    {:ok, game_id} = GameServer.new_game(difficulty: :easy)

    {:ok, game_id: game_id, initial_game_state: GameServer.get_game(game_id)}
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

  defp setup_draw(game_id) do
    for outer <- 0..1 do
      for x <- 1..3 do
        for _ <- 0..4 do
          GameServer.drop_piece(game_id, x + outer * 3)
        end
      end
      for x <- 1..3 do
        GameServer.drop_piece(game_id, x + outer * 3)
      end
    end
    for _ <- 1..5 do
      GameServer.drop_piece(game_id, 7)
    end
  end

  defp col_1_full(game_id) do
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
    GameServer.drop_piece(game_id, 1)
  end

  defp game_won(game_id) do
    setup_win(game_id)
    GameServer.drop_piece(game_id, 1)
  end
end
