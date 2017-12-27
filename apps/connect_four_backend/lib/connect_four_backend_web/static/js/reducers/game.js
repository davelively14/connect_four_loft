import {
  SET_GAME_STATE, UPDATE_STATE
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
    case UPDATE_STATE:
      return Object.assign({},
        state,
        action.state
      );
    default:
      return state;
  }
}

export default game;
