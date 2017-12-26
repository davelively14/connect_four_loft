import {
  SET_GAME_STATE,
} from '../actions/index';

var initialState = {
  id: undefined
};

function game(state = initialState, action) {
  switch(action.type) {
    case SET_GAME_STATE:
      return action.gameState;
    default:
      return state;
  }
}

export default game;
