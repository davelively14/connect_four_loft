import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as ActionCreators from '../actions/index';
import { Link } from 'react-router';
import { browserHistory } from 'react-router';

import { resetGame } from '../helpers/api';

const mapStateToProps = function(state) {
  return {
    gameId: state.game.id,
    finished: state.game.finished,
    players: {
      player_1: state.game.player_1,
      player_2: state.game.player_2
    }
  };
};

const mapDispatchToProps = function(dispatch) {
  return bindActionCreators(ActionCreators, dispatch);
};

class GameOver extends Component {
  componentWillMount() {
    if (!this.props.finished) {
      browserHistory.push('/new-game');
    }
  }

  resetGame() {
    const { updateState, gameId } = this.props;

    fetch(resetGame(gameId), {
      method: 'put'
    }).then(
      function(response) {
        return response.text();
      }
    ).then(
      function(text) {
        updateState(JSON.parse(text));
        browserHistory.push('/play-game');
      }
    );
  }

  renderWinner() {
    const { finished, players } = this.props;

    switch (finished) {
      case 'draw':
        return 'Game ended in a draw';
      default:
        return players[finished] + ' won this round!';
    }
  }

  render() {
    return(
      <div>
        <h1>Game Over</h1>
        <h3>{this.renderWinner()}</h3>
        <div className="text-center">
          <Link to="/" className="btn btn-primary">Quit</Link>&nbsp;
          <Link to="/new-game" className="btn btn-primary">New Game</Link>&nbsp;
          <button onClick={this.resetGame.bind(this)} className="btn btn-primary">Rematch</button>
        </div>
      </div>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(GameOver);
