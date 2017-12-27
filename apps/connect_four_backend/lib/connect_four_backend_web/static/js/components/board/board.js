import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';

import Row from './row';
import ColumnSelector from './column_selector';

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

  renderBoard() {
    let {board, width, height} = this.props;
    let tableBody = [];

    for (var row = height; row > 0; row--) {
      tableBody.push(Row(row, width, board));
    }

    return tableBody;
  }

  render() {
    return(
      <div>
        <table className="table table-bordered">
          <tbody>
            {this.renderBoard()}
          </tbody>
          <ColumnSelector />
        </table>
        <div className="text-center">
          <Link to="/" className="btn btn-warning">
            Leave game
          </Link>
        </div>
      </div>
    );
  }
}

export default connect(mapStateToProps, {})(Board);
