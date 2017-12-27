import React from 'react';
import { render } from 'react-dom';
import { Provider } from 'react-redux';
import { createStore } from 'redux';
import { Router, Route, IndexRoute, browserHistory } from 'react-router';
import { syncHistoryWithStore } from 'react-router-redux';

import connectFourFrontendApp from './reducers/index';
import App from './components/app';
import Landing from './components/landing';
import NewGame from './components/new_game';
import NewGameCPU from './components/new_game_cpu';
import PlayGame from './components/play_game';
import GameOver from './components/game_over';

let store = createStore(connectFourFrontendApp, window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__());
let history = syncHistoryWithStore(browserHistory, store);

render(
  <Provider store={store}>
    <Router history={history}>
      <Route path="/" component={App}>
        <IndexRoute component={Landing} />
        <Route path="new-game" component={NewGame} />
        <Route path="new-game-cpu" component={NewGameCPU} />
        <Route path="play-game" component={PlayGame} />
        <Route path="game-over" component={GameOver} />
      </Route>
    </Router>
  </Provider>,
  document.getElementById('react')
);
