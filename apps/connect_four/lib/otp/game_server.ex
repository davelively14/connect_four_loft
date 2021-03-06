defmodule ConnectFour.GameServer do
  use GenServer
  alias ConnectFour.StatusCheck

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

  def new_game(opts \\ []) do
    GenServer.call(__MODULE__, {:new_game, opts})
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
    # Assigned result for game will either be a game_state or an error tuple
    game = fetch_game_from_ets(state.ets, game_id)

    cond do
      is_tuple(game) ->
        # game will receive an error tuple if no game exists
        {:reply, game, state}
      game.finished == :draw ->
        {:reply, {:error, "The game ended in a draw."}, state}
      game.finished ->
        {:reply, {:error, "#{game.finished} already won the game."}, state}
      open_spot = find_open(game.board.free, game.height, col) ->
        new_game_state = make_move(open_spot, game)

        :ets.insert(state.ets, {game_id, new_game_state})

        if !new_game_state.finished do
          {:reply, :ok, state}
        else
          {:reply, {:ok, new_game_state.finished}, state}
        end
      true ->
        # If we make it this far, we have a column error. We first check if the
        # error is due to the column being full, otherwise it's a column outside
        # the dimensions of the board.
        unless col < 1 || col > game.width do
          {:reply, {:error, "Column #{col} is full. Choose another column."}, state}
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
        :ets.insert(state.ets, {game_id, create_new_game(game.height, game.width, game.difficulty)})
        {:reply, :ok, state}
    end
  end

  def handle_call({:new_game, opts}, _from, state) do
    if scrub_opts(opts) do
      height = opts[:height] || @default_height
      width = opts[:width] || @default_width

      cond do
        opts[:game_id] ->
          new_game = create_new_game(height, width, opts[:difficulty])

          resp = fetch_game_from_ets(state.ets, opts[:game_id])

          cond do
            is_tuple(resp) ->
              # If response is a tuple, it's an error. Returns error.
              {:reply, resp, state}
            true ->
              :ets.insert(state.ets, {opts[:game_id], new_game})
              {:reply, {:ok, opts[:game_id]}, state}
          end
        true ->
          new_game = create_new_game(height, width, opts[:difficulty])

          :ets.insert(state.ets, {state.next_id, new_game})

          {:reply, {:ok, state.next_id}, Map.put(state, :next_id, state.next_id + 1)}
      end
    else
      {:reply, {:error, "Invalid parameters"}, state}
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

  defp create_new_game(height, width, difficulty) do
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
      difficulty: difficulty
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
        finished: StatusCheck.check_win_or_draw(new_board, state.current_player, loc),
        avail_cols: new_avail_cols,
        last_play: {state.current_player, loc},
        current_player: advance_player(state.current_player)
      }
    )
  end

  defp advance_player(:player_1), do: :player_2
  defp advance_player(:player_2), do: :player_1

  defp scrub_opts([]), do: true
  defp scrub_opts(opts) do
    height = opts[:height]
    width = opts[:width]
    difficulty = opts[:difficulty]

    valid_difficulties = [:easy, :hard]

    cond do
      height && (!is_integer(height) || height < 1 || height > 10_000) ->
        false
      width && (!is_integer(width) || width < 1 || width > 10_000) ->
        false
      difficulty && !Enum.member?(valid_difficulties, difficulty) ->
        false
      true ->
        true
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
