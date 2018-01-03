# Connect Four for SalesLoft

<img src="https://image.flaticon.com/icons/png/128/12/12195.png" width="32"> &nbsp;&nbsp;<a href="https://secure-temple-90358.herokuapp.com/" target="\_blank">View Demo</a>

Connect Four app for SalesLoft [Engineering Offline Exercise v2](https://docs.google.com/document/d/1ChozkkouQrRESGlvZYEM4sNAyks5mK-cAODGSKvgYjM/edit). This is a version of the popular [Connect Four](https://en.wikipedia.org/wiki/Connect_Four) game written in the Elixir language.

## Approach

### Team

I recognize that having not worked professionally on a development team is a weakness in my work history. In order to simulate working on a team, I managed this project via GitHub. I created milestones for each level (1, 2, 3, and Boss), issues for key features in each milestone, submitted pull requests for branches that addressed each issue, and then merged from GitHub to close the issue.

Additionally, I attempted to maintain consistent convention across the board. Semicolons (JS), single quotes (JS), spacing, line breaks, directory structure, etc. were all maintained throughout.

I understand this is just a small portion of working on a team, but I wanted to make an effort to simulate doing so when able.

### Architecture

I opted to utilize Elixir's [umbrella project](http://elixir-lang.github.io/getting-started/mix-otp/dependencies-and-umbrella-apps.html) in order to manage the complexities of what are essentially three different applications: a command line interface, a web interface, and the core of the game itself. Umbrella projects are an effective method for combining Elixir applications* that share common dependencies. While these applications* are not completely decoupled, they are so loosely coupled that they can be split out into their standalone applications with relative ease.

<sup><sub> *\*Elixir inherited the term 'application' from erlang. I realize that these 'applications' function more like what is commonly referred to as a library.*</sup></sub>

## Implementation

### The Game

[Docs](https://github.com/davelively14/connect_four_loft/tree/master/apps/connect_four)

The game itself runs on a GenServer that exposes an API interface that can be accessed by other Elixir apps on the node. Each game state is maintained within an [Erlang Term Storage](http://erlang.org/doc/man/ets.html) (ets) table, which allows for quick and easy access without the added overhead of a more robust database layer. The board is stored as a map of MapSets: one for player one, a second for player two, and a third for open available locations.

For those not as familiar with Elixir, it's worth noting that although lists look like arrays, i.e.: [1, 2, 3], they can only be accessed by transversing the list. [MapSets](https://hexdocs.pm/elixir/MapSet.html) are hash array map tries and allow access at O(log(n)) time vs the O(n) time it would take to traverse a list.

The AI is accessible to the game server via the AI module.

### The CLI

[Docs](https://github.com/davelively14/connect_four_loft/tree/master/apps/cli)

The Command Line Interface is a basic OTP application. Using an Elixir script from the command line, the CLI.Supervisor will launch the server. The server simply loops through various menu options, displaying content to the user and prompting for user input via IO methods. The CLI utilizes the GameServer API to manage the actual game.

### The Web Interface

[Docs](https://github.com/davelively14/connect_four_loft/tree/master/apps/connect_four_backend) (for the backend)

I used the Phoenix framework to create a JSON API backend, which in turn utilizes our GameServer API to manage and serve game data. The docs linked above provide details on the API.

For the frontend, I used a simple ReactJS with a Redux store that interacts with the JSON API. [Bootstrap 3](http://getbootstrap.com/docs/3.3/) is used to provide a handy CSS.

## Deployed Demo

<img src="https://image.flaticon.com/icons/png/128/12/12195.png" width="32"> &nbsp;&nbsp;<a href="https://secure-temple-90358.herokuapp.com/" target="\_blank">View Demo</a>

I deployed this project to my Heroku account. It took a few iterations to get the configs right, as this was the first time I had deployed an umbrella app to Heroku, but it works.

## Initial Notes

These are the notes I used to layout my approach at the beginning of the project. Ultimately, each of these bullet points became an issue for the GitHub repo.

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
