defmodule CLITest do
  use ExUnit.Case

  describe "start/2" do
    test "will start workers" do
      assert :erlang.whereis ConnectFour.Server == :undefined
      assert :erlang.whereis CLI.Server == :undefined

      CLI.start(nil, nil)

      assert is_pid :erlang.whereis ConnectFour.GameServer
      assert is_pid :erlang.whereis CLI.Server
    end
  end
end
