# ConnectFour

The Game. This is a GenServer that exposes an API interface that can be accessed by other Elixir apps on the cluster. Each game state is maintained within an [Erlang Term Storage](http://erlang.org/doc/man/ets.html) (ets) table, which allows for quick and easy access without the added overhead of a database layer. The board is stored as a map of MapSets, one player one, a second for player two, and a third for free spaces available.

## Installation and Use

Start the server in order to access the API:

```elixir
supervisor(ConnectFour, [], [function: :start])
```

Once started, the API will be available to the cluster via the `GameServer` name. The available functions are:

- `GameServer.get_state/1`: Returns the state of the GameServer.
  - Call: `GameServer.get_state()`
  - Returns: `%{next_id: 13, ets: :games}`
    - `next_id`: The next unique id that will be used when a new game is started.
    - `ets`: The name of the ets table.
- `GameServer.drop_piece/2`: Drops a piece for a given game on the given column.
  - Call: `GameServer.drop_piece(game_id, col)`
    - `game_id`: integer (required), the id for the game
    - `col`: integer (required), the column to be played
  - Returns: `:ok` or `{:error, reason}`
- `GameServer.reset_game/1`: Resets the game to it's original configuration
  - Call: `GameServer.reset_game(game_id)`
    - `game_id`: integer (required), the id for the game
  - Returns: `:ok` or `{:error, reason}`
- `GameServer.new_game`: Creates a new game and takes an option hash
  - Call: `GameServer.new_game([height: height, width: width, difficulty: difficulty])`
    - `height`: integer (optional), the height of the board
    - `weight`: integer (optional), the width of the board
    - `difficulty`: atom (optional), either `:easy` or `:hard`
  - Returns: `{:ok, game_id}` or `{:error, reason}`
- `GameServer.get_game/1`: Returns the state of a game
  - Call: `GameServer.get_game(game_id)`
    - `game_id`: integer (required), the id for the game
  - Returns: game state as a map or `{:error, reason}`
- `GameServer.current_player/1`: Returns the current player.
  - Call: `GameServer.current_player(game_id)`
    - `game_id`: integer (required), the id for the game
  - Returns: current player (atom) or `{:error, reason}`
