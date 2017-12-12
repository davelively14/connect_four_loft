defmodule CLI.ServerTest do
  use ExUnit.Case
  alias CLI.Server
  alias ConnectFour.GameServer
  import ExUnit.CaptureIO

  setup context do
    if context[:start_game_server] do
      ConnectFour.start(nil)
    end

    start_fn = fn () ->
      CLI.start(nil, nil)
    end

    main_menu = fn () ->
      Server.select(:main_menu)
    end

    new_two_player = fn () ->
      Server.select({:new_game, 2})
    end

    game_env = fn () ->
      Server.select({:play_game, 2, %{player_1: "player 1", player_2: "player 2"}})
    end

    {:ok, %{start_fn: start_fn, main_menu: main_menu, new_two_player: new_two_player, game_env: game_env}}
  end

  # Note that passing "Q" as the first argument into all of the capture_io
  # function calls just tells our CLI to quit on the first IO.gets.

  describe "start/0" do
    test "prints a greeting", %{start_fn: start_fn} do
      assert capture_io("Q", start_fn) =~ "Welcome to Connect Four!"
    end

    test "launches the main menu" do
      assert capture_io("Q", &Server.start/0) =~ "Main Menu"
    end
  end

  describe "select(:main_menu)" do
    test "quit works regardless of case or trailing spaces", %{main_menu: main_menu} do
      assert capture_io("q ", main_menu)
      assert capture_io("Q   ", main_menu)
    end

    test "prints main menu", %{main_menu: main_menu} do
      assert capture_io("Q", main_menu) =~ "Main Menu"
    end

    test "invalid selection informs the user of such and loads main menu again", %{main_menu: main_menu} do
      assert capture_io([input: "9\nq"], main_menu) =~ "Invalid selection, please try again\n\nMain Menu"
    end
  end

  describe "select({:new_game, 2})" do
    @tag :start_game_server
    test "asks for first player's name", %{new_two_player: new_two_player} do
      assert capture_io([input: "a\nb\nq"], new_two_player) =~ "Enter first player's name"
    end

    @tag :start_game_server
    test "asks for second player's name", %{new_two_player: new_two_player} do
      assert capture_io([input: "a\nb\nq"], new_two_player) =~ "Enter second player's name"
    end

    @tag :start_game_server
    test "after entering names, launches the game", %{new_two_player: new_two_player} do
      assert capture_io([input: "a\nb\nq"], new_two_player) =~ "Let's play!"
    end
  end

  describe "select({:play_game, 2, state})" do
    @tag :start_game_server
    test "correctly alternates player", %{game_env: game_env} do
      result = capture_io([input: "1\n1\nq"], game_env)
      assert result =~ "player 1's turn"
      assert result =~ "player 2's turn"
    end

    @tag :start_game_server
    test "handles a win", %{game_env: game_env} do
      assert capture_io([input: "1\n2\n1\n2\n1\n2\n1\nq"], game_env) =~ "Congrats! player 1 has won the game!"
    end

    @tag :start_game_server
    test "handles a draw", %{game_env: game_env} do
      fill_board()
      assert capture_io([input: "7\nq"], game_env) =~ "The game has ended in a draw! Try again..."
    end

    @tag :start_game_server
    test "handles invalid input", %{game_env: game_env} do
      assert capture_io("adsf\nq", game_env) =~ "Invalid selection"
      fill_board()
      assert capture_io("2\nq", game_env) =~ "Invalid selection"
      assert capture_io("2\n7\nq", game_env) =~ "The game has ended in a draw!"
    end
  end

  describe "print_intro/0" do
    test "prints a greeting" do
      assert capture_io(&Server.print_intro/0) =~ "Welcome to Connect Four!"
    end
  end

  #####################
  # Private Functions #
  #####################

  defp fill_board do
    for outer <- 0..1 do
      for x <- 1..3 do
        for _ <- 0..4 do
          GameServer.drop_piece(x + outer * 3)
        end
      end
      for x <- 1..3 do
        GameServer.drop_piece(x + outer * 3)
      end
    end
    for _ <- 1..5 do
      GameServer.drop_piece(7)
    end
  end
end