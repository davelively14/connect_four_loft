import React from 'react';
import { render } from 'react-dom';
import { Provider } from 'react-redux';
import { createStore } from 'redux';
import { Router, Route, IndexRoute, browserHistory } from 'react-router';
import { syncHistoryWithStore } from 'react-router-redux';


import connectFourApp from './reducers/index';
import App from './components/app';
import Landing from './components/landing';

let store = createStore(connectFourApp);
let history = syncHistoryWithStore(browserHistory, store);

render(
  <Provider store={store}>
    <Router history={history}>
      <Route path="/" component={App}>
        <IndexRoute component={Landing} />
      </Route>
    </Router>
  </Provider>,
  document.getElementById('react')
);
