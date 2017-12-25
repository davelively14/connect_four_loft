# ConnectFour

Connect Four app for SalesLoft [Engineering Offline Exercise v2](https://docs.google.com/document/d/1ChozkkouQrRESGlvZYEM4sNAyks5mK-cAODGSKvgYjM/edit). This is a version of the popular [Connect Four](https://en.wikipedia.org/wiki/Connect_Four) game written in the Elixir language.

## How to Run the Command Line Interface

- Download this app to your hard drive
- From the root directory of the app, run the following:
```
$ mix deps.get
$ mix run apps/cli/lib/start_cli.exs
```

## Implementation

#### Level 1 (Complete)

- Create game mechanics
  - Store state via GenServer: board, current_player,
  - Respond to input in accordance with game rules
  - Check for wins and draw
- Create user interface for a two player game
  - CLI for a two human player version

#### Level 2 (Complete)

- Create AI
  - Block human user when able
  - Randomly select next move when choice available

#### Level 3 (Under way)

- Create backend
  - Build websocket API to serve data via backend
- Create frontend
  - Using ReactJS, build and serve a frontend
- Deploy
  - Deploy to Heroku

#### Boss (Not Started)

- Improve AI
  - Should be able to win if going first (mathematically possible)
  - Uses look-ahead strategy
