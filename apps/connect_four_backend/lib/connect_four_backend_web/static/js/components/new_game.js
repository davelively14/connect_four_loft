import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as ActionCreators from '../actions/index';
import { SubmissionError } from 'redux-form';
import { browserHistory } from 'react-router';
import { url } from '../helpers/api';

import NewGameForm from './forms/new_game_form';

const mapStateToProps = function(_state) {
  return {

  };
};

const mapDispatchToProps = function (dispatch) {
  return bindActionCreators(ActionCreators, dispatch);
};

class NewGame extends Component {
  submit(values) {
    switch (true) {
      case values.player1 == undefined:
        throw new SubmissionError({
          player1: 'Player 1 name cannot be blank',
          _error: 'Invalid name'
        });
      case values.player2 == undefined && values.difficulty == undefined:
        throw new SubmissionError({
          player2: 'Player 2 name cannot be blank',
          _error: 'Invalid name'
        });
      default:
        console.log(values);
        console.log(url());
        browserHistory.push('/');
    }
  }

  render() {
    return(
      <div className="row">
        <div className="col-sm-3" />
        <div className="col-sm-6">
          <h2>New Game</h2>
          <div className="form-group">
            <NewGameForm onSubmit={this.submit.bind(this)} />
          </div>
        </div>
      </div>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(NewGame);
