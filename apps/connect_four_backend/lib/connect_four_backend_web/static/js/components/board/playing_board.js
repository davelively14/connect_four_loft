import React, { Component } from 'react';
import { connect } from 'react-redux';

import Row from './row';

const mapStateToProps = function(state) {
  if (state.game.id) {
    return {
      board: state.game.board,
      height: state.game.height,
      width: state.game.width
    };
  } else {
    return {

    };
  }
};

class PlayingBoard extends Component {
  renderPlayingBoard() {
    let {board, width, height} = this.props;
    let tableBody = [];

    for (var row = height; row > 0; row--) {
      tableBody.push(Row(row, width, board));
    }

    return tableBody;
  }

  render() {
    return(
      <tbody>
        {this.renderPlayingBoard()}
      </tbody>
    );
  }
}

export default connect(mapStateToProps, {})(PlayingBoard);
