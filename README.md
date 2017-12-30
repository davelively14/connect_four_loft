# Connect Four for SalesLoft

Connect Four app for SalesLoft [Engineering Offline Exercise v2](https://docs.google.com/document/d/1ChozkkouQrRESGlvZYEM4sNAyks5mK-cAODGSKvgYjM/edit). This is a version of the popular [Connect Four](https://en.wikipedia.org/wiki/Connect_Four) game written in the Elixir language.

## Approach

### Team

I recognize that having not worked professionally on a development team is a weakness on my resume. In order to simulate working on a team, I managed this projects via GitHub. I created milestones for each level (1-3 and Boss), issues for key features in each milestone, submitted pull requests for branches that fixed those issues, and then merged them from GitHub to close the issues.

Additionally, I attempted to maintain consistent convention across the board. Semicolons (JS), single quotes (JS), spacing, line breaks, directory structure, etc. were all maintained throughout.

I understand this is just a small portion of working on a team, but I believe I simulated it as much as one can when working independently.

### Architecture

I opted to utilize Elixir's umbrella project capabilities in order to manage the complexities of what essentially are three different applications: a command line interface, a web interface, and the game itself. Umbrella projects are an effective method for combining Elixir applications* that share common dependencies. While these applications are not completely decoupled, they are so loosely coupled that they can easily be split out into their standalone applications.

*<sup><sub> \*Elixir inherited the term 'application' from erlang. I realize that these 'applications' function more like what is commonly referred to as a library.</sup></sub>*

## Implementation

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

## Initial Notes

These are the notes I used to layout my approach. Ultimately, each of these points became issues on the GitHub repo.

### Level 1 (Complete)

- Create game mechanics
  - Store state via GenServer
  - Respond to input in accordance with game rules
  - Check for wins and draw
- Create user interface for a two player game
  - CLI for a two human player version

### Level 2 (Complete)

- Create AI
  - Block human user when able
  - Randomly select next move when choice available

### Level 3 (Complete)

- Create backend
  - Build websocket API to serve data via backend
- Create frontend
  - Using ReactJS, build and serve a frontend
- Deploy
  - Deploy to Heroku

### Boss (Complete)

- Improve AI
  - Uses look-ahead strategy
