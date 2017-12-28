import game from '../../../lib/connect_four_backend_web/static/js/reducers/game';
import * as helpers from '../helpers/index';

const initialState = {
  id: undefined
};
const SET_GAME_STATE = 'SET_GAME_STATE';
const UPDATE_STATE = 'UPDATE_STATE';

var gameState = helpers.buildGameState();
var playerInfo = helpers.buildPlayerInfo();
var gameStore = helpers.buildGameStore();

describe('game', () => {
  it('should set default state to initialState', () => {
    expect(game(undefined, {})).to.eql(initialState);
  });

  it('should return state by default', () => {
    expect(game(gameState, {})).to.eql(gameState);
  });

  it('should set state to passed state with SET_GAME_STATE type', () => {
    expect(game(undefined, {type: SET_GAME_STATE, gameState, playerInfo})).to.eql(gameStore);
  });

  it('should update state with new values', () => {
    let resp = game(gameState, {type: UPDATE_STATE, state: {id: 5}});

    expect(resp).to.not.eql(gameState);
    expect(resp.id).to.not.eq(gameState.id);
    expect(resp.id).to.eq(5);
  });

  it('should throw a TypeError if no object passed as second arg', () => {
    expect(game.bind(undefined, undefined)).to.throw(TypeError);
  });
});
