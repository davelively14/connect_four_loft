# ConnectFourBackend

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Table of Contents

* [Create a new game](#new-game)
* [Get current state of a game](#show-game)
* [Make a move](#update-game)

## <a name="new-game"></a>Create a new game:

Creates a new game. Note that you can set the height and width of the board, as well as difficulty. If you do not provide a difficulty setting, the AI will assume it's a two player game. You may also provide an already existing game_id if you want to start that game with new settings.

By default, this will create a new, two human player game with a standard 7x6 board.

Name | Required | Type | Notes
--- | :---: | :---: | ---
*height* | no | integer | Height of board. Default is 6.
*width* | no | integer | Height of board. Default is 7.
*game_id* | no | integer | Can start a new game using an already existing game id.
*difficulty* | no | string | `easy` and `hard` are supported. Default is `null`.

API path pattern: `api/game?height=integer&width=integer&difficulty=:easy`
- If no difficulty is provided, the game will be treated as a two player game. You must select either `easy` or `hard` to begin a game with an AI opponent.
- Use the `&` operator to string together params.
- Sent via the http `POST` method.

#### Example:

HTTP Call (both achieve the same result):
```code
POST
http://localhost:4000/api/game
```
```code
POST
http://localhost:4000/api/game?height=6&width=7&game_id=1
```

Return body:
```json
{
    "width": 7,
    "last_play": null,
    "id": 1,
    "height": 6,
    "finished": null,
    "difficulty": null,
    "current_player": "player_1",
    "board": {
        "player_2": [],
        "player_1": [],
        "free": [
            [ 3, 3 ], [ 7, 6 ], [ 2, 1 ],
            [ 2, 2 ], [ 6, 4 ], [ 6, 3 ],
            [ 6, 1 ], [ 4, 5 ], [ 5, 1 ],
            [ 7, 1 ], [ 3, 1 ], [ 5, 6 ],
            [ 6, 2 ], [ 1, 3 ], [ 5, 4 ],
            [ 7, 4 ], [ 3, 5 ], [ 7, 2 ],
            [ 7, 5 ], [ 3, 4 ], [ 1, 5 ],
            [ 4, 1 ], [ 5, 2 ], [ 2, 4 ],
            [ 1, 2 ], [ 1, 4 ], [ 4, 2 ],
            [ 3, 6 ], [ 1, 6 ], [ 2, 3 ],
            [ 5, 3 ], [ 2, 6 ], [ 6, 6 ],
            [ 6, 5 ], [ 5, 5 ], [ 1, 1 ],
            [ 3, 2 ], [ 4, 6 ], [ 4, 3 ],
            [ 2, 5 ], [ 4, 4 ], [ 7, 3 ]
        ]
    },
    "avail_cols": [ 1, 2, 3, 4, 5, 6, 7 ]
}
```

## <a name="show-game"></a>Get current state of a game:

Given a valid game id, will return a JavaScript Object representing the current state of the game.

API path pattern: `api/game/id`
- Sent via the http `GET` method.

#### Example:

HTTP Call (both achieve the same result):
```code
POST
http://localhost:4000/api/game/1
```

Return body:
```json
{
    "width": 7,
    "last_play": null,
    "id": 1,
    "height": 6,
    "finished": null,
    "difficulty": null,
    "current_player": "player_1",
    "board": {
        "player_2": [],
        "player_1": [],
        "free": [
            [ 3, 3 ], [ 7, 6 ], [ 2, 1 ],
            [ 2, 2 ], [ 6, 4 ], [ 6, 3 ],
            [ 6, 1 ], [ 4, 5 ], [ 5, 1 ],
            [ 7, 1 ], [ 3, 1 ], [ 5, 6 ],
            [ 6, 2 ], [ 1, 3 ], [ 5, 4 ],
            [ 7, 4 ], [ 3, 5 ], [ 7, 2 ],
            [ 7, 5 ], [ 3, 4 ], [ 1, 5 ],
            [ 4, 1 ], [ 5, 2 ], [ 2, 4 ],
            [ 1, 2 ], [ 1, 4 ], [ 4, 2 ],
            [ 3, 6 ], [ 1, 6 ], [ 2, 3 ],
            [ 5, 3 ], [ 2, 6 ], [ 6, 6 ],
            [ 6, 5 ], [ 5, 5 ], [ 1, 1 ],
            [ 3, 2 ], [ 4, 6 ], [ 4, 3 ],
            [ 2, 5 ], [ 4, 4 ], [ 7, 3 ]
        ]
    },
    "avail_cols": [ 1, 2, 3, 4, 5, 6, 7 ]
}
```

## <a name="update-game"></a>Make a move:

Drop a token on a given column for a given game. If game has a difficulty level assigned, then the CPU will move before returning the updated game state. If a game difficulty is empty, then it is assumed a two player game. 

Name | Required | Type | Notes
--- | :---: | :---: | ---
*col* | yes | integer | Column on which to drop a token.

API path pattern: `api/game/game_id?col=valid_col`
- Sent via the http `PUT` method.

#### Example:

HTTP Call:
```code
PUT
http://localhost:4000/api/game/1?col=2
```

Return body:
```json
{
    "width": 7,
    "last_play": [
        "player_1", [ 2, 1 ]
    ],
    "id": 1,
    "height": 6,
    "finished": null,
    "difficulty": null,
    "current_player": "player_1",
    "board": {
        "player_2": [],
        "player_1": [
          [ 2, 1 ]
        ],
        "free": [
            [ 3, 3 ], [ 7, 6 ], [ 2, 1 ],
            [ 2, 2 ], [ 6, 4 ], [ 6, 3 ],
            [ 6, 1 ], [ 4, 5 ], [ 5, 1 ],
            [ 7, 1 ], [ 3, 1 ], [ 5, 6 ],
            [ 6, 2 ], [ 1, 3 ], [ 5, 4 ],
            [ 7, 4 ], [ 3, 5 ], [ 7, 2 ],
            [ 7, 5 ], [ 3, 4 ], [ 1, 5 ],
            [ 4, 1 ], [ 5, 2 ], [ 2, 4 ],
            [ 1, 2 ], [ 1, 4 ], [ 4, 2 ],
            [ 3, 6 ], [ 1, 6 ], [ 2, 3 ],
            [ 5, 3 ], [ 2, 6 ], [ 6, 6 ],
            [ 6, 5 ], [ 5, 5 ], [ 1, 1 ],
            [ 3, 2 ], [ 4, 6 ], [ 4, 3 ],
            [ 2, 5 ], [ 4, 4 ], [ 7, 3 ]
        ]
    },
    "avail_cols": [ 1, 2, 3, 4, 5, 6, 7 ]
}
```
