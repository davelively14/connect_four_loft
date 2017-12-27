import {
  SET_GAME_STATE,
} from '../actions/index';

var initialState = {
  id: undefined
};

function game(state = initialState, action) {
  switch(action.type) {
    case SET_GAME_STATE:
      return Object.assign({}, action.gameState, action.playerInfo);
    default:
      return state;
  }
}

export default game;
