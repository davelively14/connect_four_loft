import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as ActionCreators from '../actions/index';
import { Link } from 'react-router';
import { browserHistory } from 'react-router';

import Board from './board/board';

const mapStateToProps = function(state) {
  return {
    gameState: state.game,
    availCols: state.game.avail_cols || undefined,
    currentPlayer: state.game[state.game.current_player] || undefined
  };
};

const mapDispatchToProps = function(dispatch) {
  return bindActionCreators(ActionCreators, dispatch);
};

class PlayGame extends Component {
  componentWillMount() {
    if (!this.props.gameState.id) {
      browserHistory.push('/new-game');
    }
  }

  render() {
    return(
      <div className="row">
        <h2>Play the Game!</h2>
        <h3>{this.props.currentPlayer}'s turn</h3>
        <Board />
      </div>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(PlayGame);
