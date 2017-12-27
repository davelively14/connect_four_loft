/********
  TYPES
********/

// Game Types
export const SET_GAME_STATE = 'SET_GAME_STATE';
export const UPDATE_BOARD = 'UPDATE_BOARD';

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

export const updateBoard = (board) => {
  return {
    type: UPDATE_BOARD,
    board
  };
};
