import * as actions from '../../../lib/connect_four_backend_web/static/js/actions/index';
import { buildGameState, buildPlayerInfo } from '../test_helpers/helpers';

describe('index', () => {
  describe('types', () => {
    it('should return correct constant for SET_GAME_STATE', () => {
      expect(actions.SET_GAME_STATE).to.eq('SET_GAME_STATE');
    });

    it('should return correct constants for UPDATE_STATE', () => {
      expect(actions.UPDATE_STATE).to.eq('UPDATE_STATE');
    });
  });

  describe('action creators', () => {
    it('should return expected object for setGameState', () => {
      let playerInfo = buildPlayerInfo();
      let gameState = buildGameState();

      let endState = {type: actions.SET_GAME_STATE, playerInfo, gameState};

      expect(actions.setGameState(playerInfo, gameState)).to.eql(endState);
    });

    it('should return expected object for updateState', () => {
      let newGameState = buildGameState({madeMove: true});

      let endState = {type: actions.UPDATE_STATE, state: newGameState};

      expect(actions.updateState(newGameState)).to.eql(endState);
    });
  });
});
