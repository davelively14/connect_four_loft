import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
// import * as ActionCreators from '../actions/index';

import { Link } from 'react-router';

const mapStateToProps = function(_state) {
  return {

  };
};

const mapDispatchToProps = function(_dispatch) {
  // return bindActionCreators(ActionCreators, dispatch);
  return {

  };
};

class Landing extends Component {
  render() {
    return(
      <div>
        <div className="jumbotron">
          <h2>Welcome to Connect Four</h2>
          <p className="lead">My test project for <a href="https://salesloft.com/" target="_blank">SalesLoft</a></p>
          <div className="row">
            <Link to="new-game">
              <button className="btn btn-primary">New Game</button>
            </Link>
          </div>
        </div>
      </div>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Landing);
