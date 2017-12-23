defmodule ConnectFourTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  describe "start/2" do
    test "will start workers" do
      start = fn () ->
        ConnectFour.start()
      end

      assert :erlang.whereis ConnectFour.GameServer == :undefined

      assert capture_io("Q", start)

      assert is_pid :erlang.whereis ConnectFour.GameServer
    end
  end
end
