import {
  SET_GAME_STATE, UPDATE_BOARD
} from '../actions/index';

var initialState = {
  id: undefined
};

function game(state = initialState, action) {
  switch(action.type) {
    case SET_GAME_STATE:
      return Object.assign({},
        action.gameState,
        action.playerInfo
      );
    case UPDATE_BOARD:
      return Object.assign({},
        state,
        {board: action.board}
      );
    default:
      return state;
  }
}

export default game;
