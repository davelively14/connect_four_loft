import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as ActionCreators from '../actions/index';
import { SubmissionError } from 'redux-form';
import { browserHistory } from 'react-router';

import { newGame } from '../helpers/api';
import NewGameCPUForm from './forms/new_game_cpu_form';

const mapStateToProps = function(_state) {
  return {

  };
};

const mapDispatchToProps = function (dispatch) {
  return bindActionCreators(ActionCreators, dispatch);
};

class NewGameCPU extends Component {
  submit(values) {
    console.log(values);
    const { setGameState } = this.props;

    switch (true) {
      case values.player1 == undefined:
        throw new SubmissionError({
          player1: 'Player 1 name cannot be blank',
          _error: 'Invalid name'
        });
      case values.difficulty == undefined:
        throw new SubmissionError({
          player1: 'Must select a difficulty',
          _error: 'Invalid selection'
        });
      default:
        return fetch(newGame(values.difficulty), {
          method: 'post'
        }).then(
          function(response) {
            return response.text();
          }
        ).then(
          function(text) {
            setGameState({player_1: values.player1, player_2: 'CPU'}, JSON.parse(text));
            browserHistory.push('/play-game');
          }
        );
    }
  }

  render() {
    return(
      <div className="row">
        <div className="col-sm-3" />
        <div className="col-sm-6">
          <h2>New Game vs CPU</h2>
          <div className="form-group">
            <NewGameCPUForm onSubmit={this.submit.bind(this)} />
          </div>
        </div>
      </div>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(NewGameCPU);
