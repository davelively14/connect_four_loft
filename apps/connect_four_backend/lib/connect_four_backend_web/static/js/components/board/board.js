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

class Board extends Component {
  componentWillMount() {
    
  }

  printBoard() {
    let {board, width, height} = this.props;
    let tableBody = [];

    for (var row = height; row > 0; row--) {
      tableBody.push(Row(row, width, board));
    }

    return tableBody;
  }

  render() {
    return(
      <table className="table table-bordered">
        <tbody>
          {this.printBoard()}
        </tbody>
      </table>
    );
  }
}

export default connect(mapStateToProps, {})(Board);
