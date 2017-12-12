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

  def reset_ai do
    GenServer.call(__MODULE__, :reset_ai)
  end

  #############
  # Callbacks #
  #############

  def init(difficulty) do
    {:ok, initial_state(difficulty)}
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

  def handle_call(:reset_ai, _from, state) do
    {:reply, :ok, initial_state(state.initial_difficulty)}
  end

  #####################
  # Support Functions #
  #####################

  defp initial_state(difficulty) do
    %{
      initial_difficulty: difficulty,
      difficulty: difficulty
    }
  end
end
