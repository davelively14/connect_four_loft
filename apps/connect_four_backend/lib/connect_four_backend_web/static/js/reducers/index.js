import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux';
import { reducer as formReducer } from 'redux-form';

const connectFourFrontendApp = combineReducers({
  routing: routerReducer,
  form: formReducer
});

export default connectFourFrontendApp;
