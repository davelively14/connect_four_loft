defmodule ConnectFour.GameServer do
  use GenServer

  #######
  # API #
  #######

  def start_link(%{height: height, width: width}) do
    GenServer.start_link(__MODULE__, [height, width], name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  #############
  # Callbacks #
  #############

  def init([height, width]) do
    {:ok, reset_state(height, width)}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  #####################
  # Support Functions #
  #####################

  defp reset_state(height, width) do
    %{
      board: %{
        free: setup_board(height, width),
        player_1: MapSet.new(),
        player_2: MapSet.new()
      },
      current_player: 1,
      finished: nil
    }
  end

  def setup_board(width, height) do
    for x <- 1..width do
      for y <- 1..height do
        {x, y}
      end
    end |> List.flatten |> Enum.into(MapSet.new())
  end
end
