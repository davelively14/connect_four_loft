import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
// import * as ActionCreators from '../actions/index';

const mapStateToProps = function(_state) {
  return {

  };
};

const mapDispatchToProps = function(_dispatch) {
  // return bindActionCreators(ActionCreators, dispatch);
  return {

  };
};

class App extends Component {
  render() {
    return (
      <div className="container">
        {this.props.children}
      </div>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(App);
