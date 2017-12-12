defmodule ConnectFour.AIServer do
  use GenServer

  #######
  # API #
  #######

  def start_link(difficulty \\ :easy) do
    GenServer.start_link(__MODULE__, difficulty, name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def set_difficulty(difficulty) do
    GenServer.call(__MODULE__, {:set_difficulty, difficulty})
  end

  #############
  # Callbacks #
  #############

  def init(difficulty) do
    {:ok, reset_state(difficulty)}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set_difficulty, difficulty}, _from, state) do
    if difficulty in [:easy, :hard] do
      {:reply, :ok, Map.merge(state, %{difficulty: difficulty})}
    else
      {:reply, :error, state}
    end
  end

  #####################
  # Support Functions #
  #####################

  defp reset_state(difficulty) do
    %{
      difficulty: difficulty
    }
  end
end
