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

  def reset_game do
    GenServer.call(__MODULE__, :reset_game)
  end

  def current_player do
    GenServer.call(__MODULE__, :current_player)
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
      if !new_state.finished do
        {:reply, :ok, new_state}
      else
        {:reply, {:ok, new_state.finished}, new_state}
      end
    else
      {:reply, {:error, "Column #{col} is full. Chose another column."}, state}
    end
  end

  def handle_call({:drop_piece, _col}, _from, state = %{finished: finished}) do
    cond do
      finished == :draw -> {:reply, {:error, "The game ended in a draw."}, state}
      true -> {:reply, {:error, "#{state.finished} already won the game."}, state}
    end
  end

  def handle_call(:reset_game, _from, state) do
    new_state = reset_state(state.height, state.width)
    {:reply, :ok, new_state}
  end

  def handle_call(:current_player, _from, state) do
    {:reply, state.current_player, state}
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
      last_play: nil,
      avail_cols: 1..width |> Enum.to_list,
      current_player: :player_1,
      finished: nil,
      dimensions: %{height: height, width: width}
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

    new_avail_cols =
      if loc |> elem(1) == state.height do
        remove(state.avail_cols, loc |> elem(0))
      else
        state.avail_cols
      end

    Map.merge(
      state,
      %{
        board: new_board,
        finished: check_win_or_draw(state.current_player, new_free, new_player_board, loc),
        avail_cols: new_avail_cols,
        last_play: {state.current_player, loc}
      }
    )
  end

  defp advance_player(:player_1), do: :player_2
  defp advance_player(:player_2), do: :player_1

  ################
  # Check Status #
  ################

  defp check_win_or_draw(player, free, player_board, loc) do
    cond do
      check_lateral(player_board, loc) -> player
      check_vertical(player_board, loc) -> player
      check_diag_back(player_board, loc) -> player
      check_diag_fwd(player_board, loc) -> player
      MapSet.size(free) == 0 -> :draw
      true -> nil
    end
  end

  def check_lateral(player_board, {x, y}) do
    check_left(1, player_board, {x - 1, y}) |> check_right(player_board, {x + 1, y}) == 4
  end

  def check_vertical(player_board, {x, y}), do: check_vertical(1, player_board, {x, y - 1})
  defp check_vertical(4, _, _), do: true
  defp check_vertical(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_vertical(streak + 1, player_board, {x, y - 1})
    else
      false
    end
  end

  def check_diag_back(player_board, {x, y}) do
    check_up_left(1, player_board, {x - 1, y + 1}) |> check_down_right(player_board, {x + 1, y - 1}) == 4
  end

  def check_diag_fwd(player_board, {x, y}) do
    check_up_right(1, player_board, {x + 1, y + 1}) |> check_down_left(player_board, {x - 1, y - 1}) == 4
  end

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

  defp check_up_left(4, _, _), do: 4
  defp check_up_left(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_up_left(streak + 1, player_board, {x - 1, y + 1})
    else
      streak
    end
  end

  defp check_down_right(4, _, _), do: 4
  defp check_down_right(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_down_right(streak + 1, player_board, {x + 1, y - 1})
    else
      streak
    end
  end

  defp check_up_right(4, _, _), do: 4
  defp check_up_right(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_up_right(streak + 1, player_board, {x + 1, y + 1})
    else
      streak
    end
  end

  defp check_down_left(4, _, _), do: 4
  defp check_down_left(streak, player_board, loc = {x, y}) do
    if MapSet.member?(player_board, loc) do
      check_down_left(streak + 1, player_board, {x - 1, y - 1})
    else
      streak
    end
  end

  defp remove(avail_cols, col), do: remove(avail_cols, col, [])
  defp remove([], _, result), do: result |> Enum.reverse
  defp remove([head | tail], col, result) do
    if head == col do
      remove(tail, col, result)
    else
      remove(tail, col, [head | result])
    end
  end
end
