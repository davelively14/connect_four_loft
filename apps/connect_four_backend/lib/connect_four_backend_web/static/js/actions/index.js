/********
  TYPES
********/

// Game Types
export const SET_GAME_STATE = 'SET_GAME_STATE';
export const UPDATE_STATE = 'UPDATE_STATE';

/******************
  ACTION CREATORS
******************/

// Game Action Creators
export const setGameState = (playerInfo, gameState) => {
  return {
    type: SET_GAME_STATE,
    playerInfo,
    gameState
  };
};

export const updateState = (state) => {
  return {
    type: UPDATE_STATE,
    state: state
  };
};
