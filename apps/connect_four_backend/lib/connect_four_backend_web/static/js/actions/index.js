/********
  TYPES
********/

// Game Types
export const SET_GAME_STATE = 'SET_GAME_STATE';

/******************
  ACTION CREATORS
******************/

// Game Action Creators
export const setGameState = (playerInfo, gameState) => {
  return {
    type: SET_GAME_STATE,
    playerInfo: playerInfo,
    gameState: gameState
  };
};
