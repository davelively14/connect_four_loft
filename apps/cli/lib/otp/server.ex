defmodule CLI.Server do
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
      |> sanitize_selection

    options = ["1", "Q"]

    if is_valid?(selection, options) do
      IO.puts "valid"
    else
      IO.puts "invalid"
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
end
