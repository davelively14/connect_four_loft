# ConnectFour

Connect Four app for SalesLoft [Engineering Offline Exercise v2](https://docs.google.com/document/d/1ChozkkouQrRESGlvZYEM4sNAyks5mK-cAODGSKvgYjM/edit). This is a version of the popular [Connect Four](https://en.wikipedia.org/wiki/Connect_Four) game written in the Elixir language.

## Implementation

#### Level 1 (Under Construction)

- Create game mechanics
  - Store state via GenServer: board, current_player,
  - Respond to input in accordance with game rules
  - Check for wins and draw
- Create user interface for a two player game
  - CLI for a two human player version

#### Level 2 (Not Started)

- Create AI
  - Block human user when able
  - Randomly select next move when choice available

#### Level 3 (Not Started)

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
