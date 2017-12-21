defmodule ConnectFourTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  describe "start/2" do
    test "will start workers" do
      start = fn () ->
        ConnectFour.start(nil)
      end

      assert :erlang.whereis ConnectFour.GameServer == :undefined

      assert capture_io("Q", start)

      assert is_pid :erlang.whereis ConnectFour.GameServer
    end

    test "will set default width and height if non provided" do
      assert ConnectFour.start(nil)
    end

    test "will accept a different width and height" do
      assert ConnectFour.start(nil, %{width: 10, height: 10})
    end

    test "will raise error with invalid params" do
      assert_raise FunctionClauseError, fn -> ConnectFour.start(nil, %{}) end
      assert_raise FunctionClauseError, fn -> ConnectFour.start(nil, %{height: 12}) end
      assert_raise FunctionClauseError, fn -> ConnectFour.start(nil, %{width: 12}) end
      assert_raise FunctionClauseError, fn -> ConnectFour.start(nil, %{width: 12, kite: 10}) end
    end
  end
end
