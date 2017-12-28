import * as api from '../../../lib/connect_four_backend_web/static/js/helpers/api';

describe('api.url', () => {
  it('should return the base url with testing port 9876', () => {
    expect(api.url()).to.eq('http://localhost:9876/');
  });
});

describe('api.newGame', () => {
  it('should return the new game api path with no parameters', () => {
    expect(api.newGame()).to.eq('http://localhost:9876/api/game');
  });

  it('should return the new game api with difficulty', () => {
    expect(api.newGame('easy')).to.eq('http://localhost:9876/api/game?difficulty=easy');
  });
});

describe('api.makeMove', () => {
  it('should return the make move api path with proper params', () => {
    expect(api.makeMove(104, 2)).to.eq('http://localhost:9876/api/game/104?col=2');
  });
});

describe('api.resetGame', () => {
  it('should return the reset game api path', () => {
    expect(api.resetGame(104)).to.eq('http://localhost:9876/api/game/reset/104');
  });
});

describe('api.getGameState', () => {
  it('should return the get game state api path', () => {
    expect(api.getGameState(104)).to.eq('http://localhost:9876/api/game/104');
  });
});
