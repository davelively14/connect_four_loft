defmodule ConnectFour.AIServer do
  use GenServer
  alias ConnectFour.{GameServer, StatusCheck}

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

  def make_move do
    GenServer.call(__MODULE__, :make_move)
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

  def handle_call(:make_move, _from, state) do
    GameServer.get_state
    |> select_column(state.difficulty)
    |> GameServer.drop_piece

    {:reply, :ok, state}
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

  def select_column(game_state, :easy) do
    if game_state.last_play do
      if block = StatusCheck.get_block_cols(game_state), do: Enum.random(block), else: Enum.random(game_state.avail_cols)
    else
      div(game_state.width + 1, 2)
    end
  end

  def select_column(_game_state, :hard) do
    # TODO: Implement later
    # if game_state.last_play do
    #   cond do
    #     win = win_avail?(game_state) -> win
    #     block = block_opponent?(game_state) -> block
    #     true -> best_move(game_state)
    #   end
    # else
    #   div(game_state.width + 1, 2)
    # end
  end
end
