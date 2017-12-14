defmodule ConnectFour.AIServer do
  use GenServer
  alias ConnectFour.GameServer

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
      if block = block_opponent?(game_state), do: block, else: Enum.random(game_state.avail_cols)
    else
      div(game_state.width + 1, 2)
    end
  end

  def select_column(game_state, :hard) do
    if game_state.last_play do
      cond do
        win = win_avail?(game_state) -> win
        block = block_opponent?(game_state) -> block
        true -> best_move(game_state)
      end
    else
      div(game_state.width + 1, 2)
    end
  end

  def block_opponent?(%{width: width, board: board, last_play: {opponent, last_move}}) do
    cond do
      vert = check_vert(board[opponent], last_move, 3) ->
        vert
      [left, right] = check_lat(width, board[opponent], last_move, 3) ->
        cond do
          MapSet.member?(board.free, left) ->
            left |> elem(0)
          MapSet.member?(board.free, right) ->
            right |> elem(0)
          true ->
            false
        end
      true -> false
    end
    # Check status for 3 in a row
  end

  def win_avail?(game_state) do
    # Do I have three in a row?
  end

  def best_move(game_state) do
    # Make best move avail
  end

  ################
  # Check Status #
  ################

  defp check_vert(player_board, {x, y}, distance), do: check_vert(1, player_board, {x, y - 1}, distance)
  defp check_vert(streak, _, {x, _}, distance) when streak == distance, do: x
  defp check_vert(streak, player_board, loc = {x, y}, distance) do
    if MapSet.member?(player_board, loc) do
      check_vert(streak + 1, player_board, {x, y - 1}, distance)
    else
      false
    end
  end

  def check_lat(width, player_board, {x, y}, distance) do
    # left = check_left(1, player_board, {x - 1, y}, distance)
    # right = check_right(1, player_board, {x - 1, y}, distance)
    # 
    # if left + right == distance do
    #   [{x - left, y}, {x + right, y}]
    # else
    #   false
    # end
  end

  defp check
end
