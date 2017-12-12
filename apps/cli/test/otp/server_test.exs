defmodule CLI.ServerTest do
  use ExUnit.Case
  alias CLI.Server
  import ExUnit.CaptureIO

  setup do
    start_fn = fn () ->
      CLI.start(nil, nil)
    end

    main_menu = fn () ->
      Server.select(:main_menu)
    end

    {:ok, %{start_fn: start_fn, main_menu: main_menu}}
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

  describe "print_intro/0" do
    test "prints a greeting" do
      assert capture_io(&Server.print_intro/0) =~ "Welcome to Connect Four!"
    end
  end
end
