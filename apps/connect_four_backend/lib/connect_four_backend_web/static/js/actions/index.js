/********
  TYPES
********/

// Game Types
export const SET_GAME_STATE = 'SET_GAME_STATE';

/******************
  ACTION CREATORS
******************/

// Game Action Creators
export const setGameState = (gameState) => {
  return {
    type: SET_GAME_STATE,
    gameState: gameState
  };
};
