# Connect Four for SalesLoft

Connect Four app for SalesLoft [Engineering Offline Exercise v2](https://docs.google.com/document/d/1ChozkkouQrRESGlvZYEM4sNAyks5mK-cAODGSKvgYjM/edit). This is a version of the popular [Connect Four](https://en.wikipedia.org/wiki/Connect_Four) game written in the Elixir language.

## Approach

I opted to utilize Elixir's umbrella project capabilities in order to manage the complexities of what essentially are three different applications: a command line interface, a web interface, and the game itself. Umbrella projects are an effective method for combining Elixir applications* that share common dependencies. While these applications are not completely decoupled, they are so loosely coupled that they can easily be split out into their standalone applications.

<h4><small>* Elixir inherited the term 'application' from erlang. I realize that these 'applications' function more like what is commonly referred to as a library.</small></h4>

### The Game

[Docs](https://github.com/davelively14/connect_four_loft/tree/master/apps/connect_four)

The game itself runs on a GenServer that exposes an API interface that can be accessed by other Elixir apps on the cluster. Each game state is maintained within an [Erlang Term Storage](http://erlang.org/doc/man/ets.html) (ets) table, which allows for quick and easy access without the added overhead of a database layer. The board is stored as a map of MapSets, one player one, a second for player two, and a third for free spaces available.

For those not as familiar with Elixir, it's worth noting that although lists look like arrays, i.e.: [1, 2, 3], they can only be accessed by transversing the list. MapSets are hash array map tries and allow access at O(log(n)) time vs the O(n) time it would take to traverse a list.

The AI is accessible to the game via module.

### The CLI

[Docs](https://github.com/davelively14/connect_four_loft/tree/master/apps/cli)

The Command Line Interface is a basic OTP application. Using an Elixir script from the command line, the CLI.Supervisor will launch the server. The server simply loops through various menu options, displaying content to the user and prompting for user input via IO methods. Connects with the GameServer, which manages the actual game.

### The Web Interface

[Docs](https://github.com/davelively14/connect_four_loft/tree/master/apps/connect_four_backend) (for the backend)

I used the Phoenix framework to create a JSON API backend, which in turn utilizes our GameServer API in order to manage and serve data. The docs listed above provide details on the API.

For the frontend, I used a simple ReactJS with a Redux store that interacts with the JSON API. Bootstrap 3 is used for CSS assistance.

## Deployed Demo

<img src="https://image.flaticon.com/icons/png/128/12/12195.png" width="32"> &nbsp;&nbsp;<a href="https://secure-temple-90358.herokuapp.com/" target="\_blank">View Demo</a>

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

#### Level 3 (Complete)

- Create backend
  - Build websocket API to serve data via backend
- Create frontend
  - Using ReactJS, build and serve a frontend
- Deploy
  - Deploy to Heroku

#### Boss (Complete)

- Improve AI
  - Uses look-ahead strategy
