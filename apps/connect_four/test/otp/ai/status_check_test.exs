defmodule ConnectFour.StatusCheckTest do
  use ExUnit.Case
  alias ConnectFour.StatusCheck

  describe "check_vert/3" do
    test "returns column with correct consecutive pieces met" do
      assert StatusCheck.check_vert(player_board_3_vert(), {1, 3}, 3) == 1
    end

    test "does not return column if not enough consecutive pieces" do
      refute StatusCheck.check_vert(player_board_3_vert(), {1, 3}, 4)
      refute StatusCheck.check_vert(MapSet.new(), {1, 4}, 4)
      refute StatusCheck.check_vert(MapSet.new(), {1, 4}, 1)
    end

    test "returns column if more than necessary consecutive pieces" do
      assert StatusCheck.check_vert(player_board_3_vert(), {1, 3}, 2) == 1
    end
  end

  #####################
  # Private Functions #
  #####################

  defp player_board_3_vert do
    MapSet.new([{1, 3}, {1, 2}, {1, 1}])
  end
end
