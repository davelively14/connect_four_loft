import * as actions from '../../../lib/connect_four_backend_web/static/js/actions/index';

describe('index', () => {
  describe('types', () => {
    it('should return correct constants for Game', () => {
      expect(actions.SET_GAME_STATE).to.eq('SET_GAME_STATE');
    });
  });
});
