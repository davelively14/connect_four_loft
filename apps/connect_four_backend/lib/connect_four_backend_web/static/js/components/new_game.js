import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

const mapStateToProps = function(_state) {
  return {

  };
};

class NewGame extends Component {
  render() {
    return(
      <div>
        <h2>New Game</h2>
      </div>
    );
  }
}

export default connect(mapStateToProps, {})(NewGame);
