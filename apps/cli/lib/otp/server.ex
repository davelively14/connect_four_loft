defmodule CLI.Server do
  alias ConnectFour.GameServer

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
    IO.puts "Q - Quit the game at any point"
    IO.puts "----------"
    selection =
      IO.gets "Make a selection: "

    selection = selection |> sanitize_selection

    options = ["1", "Q"]

    if is_valid?(selection, options) do
      case selection do
        "Q" ->
          exit_game()
        "1" ->
          select({:new_game, 2})
        _ ->
          select(:main_menu)
      end
    else
      invalid(:main_menu)
    end
  end

  def select({:new_game, 2}) do
    player_1 = IO.gets "Enter first player's name: "
    player_2 = IO.gets "Enter second player's name: "
    select({:play_game, 2, %{player_1: player_1, player_2: player_2}})
    IO.puts "Let's play!\nEnter 'q' at any time to quit the game."
  end

  def select({:play_game, 2, state}) do
    game_state = GameServer.get_state
    options = prep_options(game_state.avail_cols)

    IO.puts "Available columns: #{Enum.join(game_state.avail_cols, ", ")}"
    selection = IO.gets "#{state[game_state.current_player]}'s turn. Select a column: "

    selection = selection |> sanitize_selection

    if is_valid?(selection, options) do
      if selection == "Q" do
        exit_game()
      else
        result = GameServer.drop_piece(String.to_integer(selection))

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
  defp print_result(winner), do: IO.puts "Congrats! #{winner} has won the game!\n\n"
end
