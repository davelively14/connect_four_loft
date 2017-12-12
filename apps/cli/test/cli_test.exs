defmodule CLITest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  describe "start/2" do
    test "will start workers" do
      func = fn () ->
        CLI.start(nil, nil)
      end
      assert :erlang.whereis ConnectFour.Server == :undefined

      assert capture_io("Q", func)

      assert is_pid :erlang.whereis ConnectFour.GameServer
    end
  end
end
