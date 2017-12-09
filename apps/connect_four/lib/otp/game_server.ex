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

  def drop_piece(col) do
    GenServer.call(__MODULE__, {:drop_piece, col})
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

  def handle_call({:drop_piece, col}, _from, state = %{finished: nil}) do
    if open_spot = find_open(state.board.free, state.height, col) do
      new_state =
        make_move(open_spot, state)
        |> Map.merge(%{current_player: advance_player(state.current_player)})
      # TODO Reply back :ok for good move, or a result if draw/won
      {:reply, :ok, new_state}
    else
      {:reply, {:error, "Row is full"}, state}
    end
  end

  def handle_call({:drop_piece, _col}, _from, state = %{finished: finished}) do
    cond do
      finished == :draw -> {:reply, {:error, "The game ended in a draw."}, state}
      true -> {:reply, {:error, "#{state.finished} already won the game."}}
    end
  end

  #####################
  # Support Functions #
  #####################

  defp reset_state(height, width) do
    %{
      board: %{
        free: setup_board(width, height),
        player_1: MapSet.new(),
        player_2: MapSet.new()
      },
      height: height,
      width: width,
      current_player: :player_1,
      finished: nil
    }
  end

  defp setup_board(width, height) do
    for x <- 1..width do
      for y <- 1..height do
        {x, y}
      end
    end |> List.flatten |> Enum.into(MapSet.new())
  end

  defp find_open(free, height, col), do: _find_open(free, height, {col, 1})
  defp _find_open(_, height, {_, row}) when row > height, do: nil
  defp _find_open(free, height, elem = {col, row}) do
    cond do
      MapSet.member?(free, elem) -> elem
      true -> _find_open(free, height, {col, row + 1})
    end
  end

  # Returns state
  defp make_move(loc, state) do
    new_free = MapSet.delete(state.board.free, loc)
    new_player_board = MapSet.put(state.board[state.current_player], loc)
    new_board =
      Map.merge(state.board, Map.new([{state.current_player, new_player_board}]))
      |> Map.merge(%{free: new_free})
    Map.merge(state, %{board: new_board, finished: check_win(state.current_player, new_player_board, loc)})
  end

  defp advance_player(:player_1), do: :player_2
  defp advance_player(:player_2), do: :player_1

  ################
  # Check Status #
  ################

  defp check_win(player, player_board, loc) do
    cond do
      check_lateral(player_board, loc) -> player
      # check_vertical(player_board, loc) -> player
      true -> nil
    end
  end

  def check_lateral(player_board, {x, y}) do
    check_left(1, player_board, {x - 1, y}) |> check_right(player_board, {x + 1, y}) == 4
  end

  # def check_vertical(player_board, {x, y}) do
  #   check_up(0, player_board, loc)
  # end

  defp check_left(4, _, _), do: 4
  defp check_left(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_left(streak + 1, player_board, {x - 1, y})
    else
      streak
    end
  end

  defp check_right(4, _, _), do: 4
  defp check_right(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_right(streak + 1, player_board, {x + 1, y})
    else
      streak
    end
  end
end
