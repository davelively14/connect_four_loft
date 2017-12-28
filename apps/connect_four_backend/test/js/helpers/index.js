export function buildGameState(opts = {}) {
  let baseGame = {
    id: 1,
    board: {
      free: [[1, 1], [1, 2], [2, 1], [2, 2]],
      player_1: [],
      player_2: []
    },
    height: 2,
    width: 2,
    last_play: undefined,
    avail_cols: [1, 2],
    current_player: 'player_1',
    finished: undefined,
    difficulty: undefined
  };

  if (opts.madeMove) {
    return Object.assign({},
      baseGame,
      {
        board: {
          free: [[1, 2], [2, 1], [2, 2]],
          player_1: [[1, 1]],
          player_2: []
        },
        current_player: 'player_2',
        last_play: ['player_1', [1, 1]]
      }
    );
  } else {
    return baseGame;
  }
}

export function buildPlayerInfo(opts = {}) {
  return {
    player_1: opts.player_1 || 'first',
    player_2: opts.player_2 || 'second'
  };
}

export function buildGameStore() {
  return Object.assign({},
    buildGameState(),
    buildPlayerInfo()
  );
}
