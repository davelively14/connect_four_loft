defmodule ConnectFour.GameServer do
  use GenServer

  #######
  # API #
  #######

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  #############
  # Callbacks #
  #############

  def init(_) do
    {:ok, default_state()}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  #####################
  # Support Functions #
  #####################

  defp default_state do
    %{
      board: %{
        free: setup_board(7, 6),
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
