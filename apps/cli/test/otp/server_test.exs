defmodule CLI.ServerTest do
  use ExUnit.Case
  alias CLI.Server
  import ExUnit.CaptureIO

  setup do
    CLI.start(nil, nil)
    :ok
  end

  # Note that passing "Q" as the first argument into all of the capture_io
  # function calls just tells our CLI to quit on the first IO.gets.

  describe "start/0" do
    test "prints a greeting" do
      assert capture_io("Q", &Server.start/0) =~ "Welcome to Connect Four!"
    end

    test "launches the main menu" do
      assert capture_io("Q", &Server.start/0) =~ "Main Menu"
    end
  end

  describe "select(:main_menu)" do
    test "prints main menu" do
      selection = :main_menu
      func = fn () ->
        Server.select(selection)
      end

      assert capture_io("Q", func) =~ "Main Menu"
    end
  end

  describe "print_intro/0" do
    test "prints a greeting" do
      assert capture_io(&Server.print_intro/0) =~ "Welcome to Connect Four!"
    end
  end
end
