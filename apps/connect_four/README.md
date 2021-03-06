# ConnectFour

The Game. This is a GenServer that exposes an API interface that can be accessed by other Elixir apps on the cluster. Each game state is maintained within an [Erlang Term Storage](http://erlang.org/doc/man/ets.html) (ets) table, which allows for quick and easy access without the added overhead of a database layer. The board is stored as a map of MapSets, one player one, a second for player two, and a third for free spaces available.

## Installation

Start the server in order to access the API:

```elixir
supervisor(ConnectFour, [], [function: :start])
```

Once started, the API will be available to the node via the `ConnectFour.GameServer` name.

## API

### Table of Contents

* [new_game](#new-game)
* [get_game](#get-game)
* [get_state](#get-state)
* [drop_piece](#drop-piece)
* [reset_game](#reset-game)
* [current_player](#current-player)

### <a name="new-game"></a>new_game

Creates a new game. Takes an option hash, or starts the game with defaults if not provided.

Name | Required | Type | Notes
--- | :---: | :---: | ---
*height* | no | integer | Height of board. Default is 6.
*width* | no | integer | Height of board. Default is 7.
*difficulty* | no | atom | `:easy` or `:hard` are supported. Default is `nil`.

Call:
```elixir
# Uses defaults
GameState.new_game()

# Uses provided parameters
GameState.new_game(%{height: 10, width: 10, difficulty: :easy})
```

Returns one of the following:
- `{:ok, game_id}`: If valid, will return a tuple with `:ok` and a game id in integer format.
- `{:error, reason}`: If error, will return a tuple with `:error` and a string representing the reason for the error.

#### Example:

```
iex> GameState.new_game(%{height: 3, width: 6, difficulty: :easy})
{:ok, 2}
iex> GameState.new_game()
{:ok, 3}
```

### <a name="get-game"></a>get_game

Provided a valid `game_id`, returns the state of the given game.

Name | Required | Type | Notes
--- | :---: | :---: | ---
*game_id* | yes | integer | The id of the game being played.

Call:
```elixir
GameState.get_game(game_id)
```

With a valid id, returns the game state as a map with the following keys
- `board`: a map with the following keys
  - `free`: MapSet with a collection of coordinates representing moves available to players.
  - `player_1`: MapSet with a collection of coordinates representing moves made by player 1
  - `player_2`: MapSet with a collection of coordinates representing moves made by player 2
- `height`: integer representing the height of the board
- `width`: integer representing width of the board
- `last_play`: either `nil`, if no play has been made, or a tuple representing last move `{player, {x, y}}`
- `avail_cols`: list of integers representing columns with moves available to the players
- `current_player`: atom for the current player. Either `:player_1` or `:player_2`
- `finished`: `nil` by default, or with the outcome of the game once conditions have been made, either `:player_1`, `:player_2`, or `:draw`.
- `difficulty`: atom representing level of difficulty. Either `:easy` or `:hard`.

Otherwise, returns an error:
- `{:error, reason}`: tuple with `:error` and a string representing the reason for the error.

#### Example:

```
iex> GameState.get_game(1)
%{avail_cols: [1, 2, 3, 4, 5, 6, 7],
  board: %{free: #MapSet<[{3, 3}, {7, 6}, {2, 1}, {2, 2}, {6, 4}, {6, 3},
     {6, 1}, {4, 5}, {5, 1}, {7, 1}, {3, 1}, {5, 6}, {6, 2}, {1, 3}, {5, 4},
     {7, 4}, {3, 5}, {7, 2}, {7, 5}, {3, 4}, {1, 5}, {4, 1}, {5, 2}, {2, 4},
     {1, 2}, {1, 4}, {4, 2}, {3, 6}, {1, 6}, {2, 3}, {5, 3}, {2, 6}, {6, 6},
     {6, 5}, {5, 5}, {1, 1}, {3, 2}, {4, 6}, {4, 3}, {2, 5}, {4, 4}, {7, 3}]>,
    player_1: #MapSet<[]>, player_2: #MapSet<[]>}, current_player: :player_1,
  difficulty: nil, finished: nil, height: 6, last_play: nil, width: 7}
```

### <a name="get-state"></a>get_state

Returns the state of the GameServer. Note that this only includes settings for the GameServer itself. To retrieve the state of a particular game, go to the [get_game](#get-game) function.

Call:
```elixir
GameState.get_state()
```

Returns a map with two keys:
- `next_id`: The next unique id that will be used when a new game is started.
- `ets`: The name of the ets table.

#### Example:

```
iex> GameState.get_state()
%{next_id: 13, ets: :games}
```

### <a name="drop-piece"></a>drop_piece

Drops a piece for a given game on the given column.

Name | Required | Type | Notes
--- | :---: | :---: | ---
*game_id* | yes | integer | The id of the game being played.
*col* | yes | integer | The column where the piece is to be dropped.

Call:
```elixir
GameState.drop_piece(game_id, col)
```

Returns one of:
- `:ok`: Indicates the play was valid and recorded.
- `{:error, reason}`: If error, will return a tuple with `:error` and a string representing the reason for the error.

#### Example:

```
iex> GameState.drop_piece(123, 4)
:ok
iex> GameState.drop_piece(124, 4)
{:error, "Game does not exist"}
```

### <a name="reset-game"></a>reset_game

With a valid game_id, resets the game to it's original configuration.

Name | Required | Type | Notes
--- | :---: | :---: | ---
*game_id* | yes | integer | The id of the game to be reset.

Call:
```elixir
GameState.reset_game(game_id)
```

Returns one of:
- `:ok`: Indicates the game has been reset successfully.
- `{:error, reason}`: If error, will return a tuple with `:error` and a string representing the reason for the error.

#### Example:

```
iex> GameState.reset_game(1)
:ok
iex> GameState.reset_game(124)
{:error, "Game does not exist"}
```

### <a name="current-player"></a>current_player

With a valid game id, returns the current player.

Name | Required | Type | Notes
--- | :---: | :---: | ---
*game_id* | yes | integer | The id of the game being played.

Call:
```elixir
GameState.current_player(game_id)
```

Returns one of:
- `player`: An atom representing the current player. Either `:player_1` or `:player_2`.
- `{:error, reason}`: If error, will return a tuple with `:error` and a string representing the reason for the error.

#### Example:

```
iex> GameState.current_player(1)
:player_1
iex> GameState.current_player(124)
{:error, "Game does not exist"}
```
