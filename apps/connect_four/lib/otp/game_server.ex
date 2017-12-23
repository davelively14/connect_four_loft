defmodule ConnectFour.GameServer do
  use GenServer

  @default_height 6
  @default_width 7

  #######
  # API #
  #######

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def drop_piece(game_id, col) do
    GenServer.call(__MODULE__, {:drop_piece, game_id, col})
  end

  def reset_game(game_id) do
    GenServer.call(__MODULE__, {:reset_game, game_id})
  end

  def new_game, do: new_game(@default_height, @default_width)
  def new_game(height, width) do
    GenServer.call(__MODULE__, {:new_game, height, width})
  end
  def new_game(game_id), do: new_game(game_id, @default_height, @default_width)
  def new_game(game_id, height, width) do
    GenServer.call(__MODULE__, {:new_game, game_id, height, width})
  end

  def get_game(game_id) do
    GenServer.call(__MODULE__, {:get_game, game_id})
  end

  def current_player(game_id) do
    GenServer.call(__MODULE__, {:current_player, game_id})
  end

  #############
  # Callbacks #
  #############

  def init(_) do
    ets =
      if :ets.info(:games) == :undefined do
        :ets.new(:games, [:set, :private, :named_table])
      else
        :ets.delete(:games)
        :ets.new(:games, [:set, :private, :named_table])
      end

    {:ok, %{next_id: 1, ets: ets}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:drop_piece, game_id, col}, _from, state) do
    game = fetch_game_from_ets(state.ets, game_id)

    cond do
      is_tuple(game) ->
        {:reply, game, state}
      game.finished == :draw ->
        {:reply, {:error, "The game ended in a draw."}, state}
      game.finished ->
        {:reply, {:error, "#{game.finished} already won the game."}, state}
      open_spot = find_open(game.board.free, game.height, col) ->
        new_game_state =
          make_move(open_spot, game)
          |> Map.merge(%{current_player: advance_player(game.current_player)})

        :ets.insert(state.ets, {game_id, new_game_state})

        if !new_game_state.finished do
          {:reply, :ok, state}
        else
          {:reply, {:ok, new_game_state.finished}, state}
        end
      true ->
        unless col < 1 || col > game.width do
          {:reply, {:error, "Column #{col} is full. Chose another column."}, state}
        else
          {:reply, {:error, "Invalid column"}, state}
        end
    end
  end

  def handle_call({:reset_game, game_id}, _from, state) do
    game = fetch_game_from_ets(state.ets, game_id)

    cond do
      is_tuple(game) ->
        {:reply, game, state}
      true ->
        :ets.insert(state.ets, {game_id, create_new_game(game.height, game.width)})
        {:reply, :ok, state}
    end
  end

  def handle_call({:new_game, height, width}, _from, state) do
    new_game = create_new_game(height, width)

    :ets.insert(state.ets, {state.next_id, new_game})

    {:reply, {:ok, state.next_id}, Map.put(state, :next_id, state.next_id + 1)}
  end

  def handle_call({:new_game, game_id, height, width}, _from, state) do
    new_game = create_new_game(height, width)

    resp = fetch_game_from_ets(state.ets, game_id)

    cond do
      is_tuple(resp) ->
        {:reply, resp, state}
      true ->
        :ets.insert(state.ets, {game_id, new_game})
        {:reply, {:ok, state.next_id}, Map.put(state, :next_id, state.next_id + 1)}
    end
  end

  def handle_call({:get_game, game_id}, _from, state) do
    {:reply, fetch_game_from_ets(state.ets, game_id), state}
  end

  def handle_call({:current_player, game_id}, _from, state) do
    game = fetch_game_from_ets(state.ets, game_id)

    cond do
      is_tuple(game) ->
        {:reply, game, state}
      true ->
        {:reply, game.current_player, state}
    end
  end

  #####################
  # Support Functions #
  #####################

  defp create_new_game(height, width) do
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
      difficulty: nil
    }
  end

  defp fetch_game_from_ets(ets, game_id) do
    case :ets.lookup(ets, game_id) do
      [] ->
        {:error, "Game does not exist"}
      [{_, game}] ->
        game
      _ ->
        {:error, "Unknown"}
    end
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
