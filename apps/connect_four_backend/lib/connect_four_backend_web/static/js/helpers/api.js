export const url = () => {
  if (window.location.port) {
    return window.location.protocol + '//' + window.location.hostname + ':' + window.location.port + '/';
  } else {
    return window.location.protocol + '//' + window.location.hostname + '/';
  }
};

export const newGame = (difficulty = undefined) => {
  if (difficulty) {
    return url() + 'api/game?difficulty=' + difficulty;
  } else {
    return url() + 'api/game';
  }
};

export const makeMove = (gameId, col) => {
  return url() + 'api/game/' + gameId + '?col=' + col;
};

export const resetGame = (gameId) => {
  return url() + 'api/game/reset/' + gameId;
};

export const getGameState = (gameId) => {
  return url() + 'api/game/' + gameId;
};
