defmodule CLI.Server do
  alias ConnectFour.{GameServer, AI}

  #######
  # API #
  #######

  def start do
    print_intro()
    select(:main_menu)
  end

  #############
  # Callbacks #
  #############

  def select(:main_menu) do
    IO.puts "Main Menu"
    IO.puts "----------"
    IO.puts "1 - Start new game for two human players"
    IO.puts "2 - Start new game vs easy CPU opponent"
    IO.puts "3 - Start new game vs hard CPU opponent"
    IO.puts "Q - Quit the game at any point"
    IO.puts "----------"
    selection =
      IO.gets "Make a selection: "

    selection = selection |> sanitize_selection

    options = ["1", "2", "3", "Q"]

    if is_valid?(selection, options) do
      case selection do
        "Q" ->
          exit_game()
        "1" ->
          select({:new_game, 2})
        "2" ->
          select({:new_game, :easy})
        "3" ->
          select({:new_game, :hard})
        _ ->
          select(:main_menu)
      end
    else
      invalid(:main_menu)
    end
  end

  def select({:new_game, 2}) do
    {:ok, game_id} = GameServer.new_game()
    player_1 = IO.gets "Enter first player's name: "
    player_2 = IO.gets "Enter second player's name: "
    IO.puts "Let's play!\nEnter 'q' at any time to quit the game."
    select({:play_game, 2, %{player_1: player_1, player_2: player_2, game_id: game_id}})
  end

  def select({:new_game, difficulty}) do
    {:ok, game_id} = GameServer.new_game()
    player_1 = IO.gets "Enter player's name: "
    IO.puts "Let's play!\nEnter 'q' at any time to quit the game."
    select({:play_game, difficulty, %{player_1: player_1, player_2: "CPU", game_id: game_id}})
  end

  def select({:play_game, 2, state}) do
    game_state = GameServer.get_game(state.game_id)
    options = prep_options(game_state.avail_cols)

    print_board(game_state)
    selection = IO.gets "#{state[game_state.current_player] |> String.trim_trailing}'s turn. Select a column: "

    selection = selection |> sanitize_selection

    if is_valid?(selection, options) do
      if selection == "Q" do
        exit_game()
      else
        result = GameServer.drop_piece(state.game_id, String.to_integer(selection))

        case result do
          :ok ->
            IO.puts "Added a piece to column #{selection}"
            select({:play_game, 2, state})
          {:ok, :draw} ->
            print_result(:draw)
            select(:main_menu)
          {:ok, winner} ->
            print_result(state[winner])
            select(:main_menu)
          {:error, message} ->
            IO.puts "#{message}\n\n"
            select({:play_game, 2, state})
          _ ->
            IO.puts "Unknown error, restarting"
            select(:main_menu)
        end
      end
    else
      invalid({:play_game, 2, state})
    end
  end

  def select({:play_game, difficulty, state}) do
    game_state = GameServer.get_game(state.game_id)
    options = prep_options(game_state.avail_cols)

    print_board(game_state)
    selection = IO.gets "#{state[game_state.current_player] |> String.trim_trailing}'s turn. Select a column: "

    selection = selection |> sanitize_selection

    if is_valid?(selection, options) do
      if selection == "Q" do
        exit_game()
      else
        result = GameServer.drop_piece(state.game_id, String.to_integer(selection))

        case result do
          :ok ->
            IO.puts "Added a piece to column #{selection}"
            cpu_play = AI.select_column(GameServer.get_game(state.game_id), difficulty)

            case GameServer.drop_piece(state.game_id, cpu_play) do
              :ok ->
                IO.puts "CPU adds a piece to column #{cpu_play}"
                select({:play_game, difficulty, state})
              {:ok, :draw} ->
                print_result(:draw)
                select(:main_menu)
              {:error, message} ->
                IO.puts "#{message}\n\n"
                select({:play_game, difficulty, state})
              {:ok, winner} ->
                print_result(state[winner])
                select(:main_menu)
              _ ->
                IO.puts "Unknown error, restarting"
                select(:main_menu)
            end
          {:ok, :draw} ->
            print_result(:draw)
            select(:main_menu)
          {:ok, winner} ->
            print_result(state[winner])
            select(:main_menu)
          {:error, message} ->
            IO.puts "#{message}\n\n"
            select({:play_game, difficulty, state})
          _ ->
            IO.puts "Unknown error, restarting"
            select(:main_menu)
        end
      end
    else
      invalid({:play_game, difficulty, state})
    end
  end

  ########################
  # Supporting Functions #
  ########################

  def print_intro do
    IO.puts "Welcome to Connect Four! Make your selections by typing in a number corresponding to your choice and pressing return."
  end

  def is_valid?(selection, options), do: _is_valid?(selection, options)
  defp _is_valid?(_selection, []), do: false
  defp _is_valid?(selection, [head | tail]) do
    if selection == head, do: true, else: _is_valid?(selection, tail)
  end

  defp sanitize_selection(selection), do: selection |> String.trim_trailing |> String.upcase

  defp invalid(destination) do
    IO.puts "\nInvalid selection, please try again\n"
    select(destination)
  end

  defp exit_game do
    IO.puts "Thanks for playing!"
  end

  defp prep_options(options), do: prep_options(options |> Enum.map(&(&1)), [])
  defp prep_options([], result), do: ["Q" | result]
  defp prep_options([head | tail], result), do: prep_options(tail, [to_string(head) | result])

  defp print_result(:draw), do: IO.puts "The game has ended in a draw! Try again...\n\n"
  defp print_result(winner), do: IO.puts "Congrats! #{winner |> String.trim_trailing} has won the game!\n\n"

  def print_board(game_state) do
    for y <- game_state.height..1 do
      IO.puts print_row(game_state.board, y, 1..game_state.width |> Enum.to_list)
    end
    IO.puts print_lower_border(game_state.width)
    IO.puts print_column_footers(game_state.width)
  end

  defp print_row(board, row, cols), do: print_row(board, row, cols, "| ")
  defp print_row(_, _, [], result), do: result
  defp print_row(board, row, [col | tail], result) do
    cond do
      MapSet.member?(board.free, {col, row}) ->
        print_row(board, row, tail, result <> "-  ")
      MapSet.member?(board.player_1, {col, row}) ->
        print_row(board, row, tail, result <> "1  ")
      MapSet.member?(board.player_2, {col, row}) ->
        print_row(board, row, tail, result <> "2  ")
      true ->
        :error
    end
  end

  defp print_lower_border(width), do: print_lower_border(1..width |> Enum.to_list, "|-")
  defp print_lower_border([], result), do: result
  defp print_lower_border([_ | tail], result), do: print_lower_border(tail, result <> "---")

  defp print_column_footers(width), do: print_column_footers(1..width |> Enum.to_list, "  ")
  defp print_column_footers([], result), do: result
  defp print_column_footers([head | tail], result), do: print_column_footers(tail, result <> "#{head}  ")
end
