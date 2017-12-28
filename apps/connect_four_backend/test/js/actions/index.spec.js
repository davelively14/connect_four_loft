import * as actions from '../../../lib/connect_four_backend_web/static/js/actions/index';

describe('index', () => {
  describe('types', () => {
    it('should return correct constant for SET_GAME_STATE', () => {
      expect(actions.SET_GAME_STATE).to.eq('SET_GAME_STATE');
    });

    it('should return correct constants for UPDATE_STATE', () => {
      expect(actions.UPDATE_STATE).to.eq('UPDATE_STATE');
    });
  });

  describe('action creators', () => {
    it('should return expected object for setGameState', () => {
      let playerInfo = buildPlayerInfo();
      let gameState = buildGameState();

      let endState = {type: actions.SET_GAME_STATE, playerInfo, gameState};

      expect(actions.setGameState(playerInfo, gameState)).to.eql(endState);
    });

    it('should return expected object for updateState', () => {
      let newGameState = buildGameState({madeMove: true});

      let endState = {type: actions.UPDATE_STATE, state: newGameState};

      expect(actions.updateState(newGameState)).to.eql(endState);
    });
  });
});

/********************
  SUPPORT FUNCTIONS
********************/

function buildGameState(opts = {}) {
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

function buildPlayerInfo(opts = {}) {
  return {
    player_1: opts.player_1 || 'first',
    player_2: opts.player_2 || 'second'
  };
}
