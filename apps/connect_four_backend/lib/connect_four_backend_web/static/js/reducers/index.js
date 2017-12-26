import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux';
import { reducer as formReducer } from 'redux-form';

import game from './game';

const connectFourFrontendApp = combineReducers({
  game,
  routing: routerReducer,
  form: formReducer
});

export default connectFourFrontendApp;
