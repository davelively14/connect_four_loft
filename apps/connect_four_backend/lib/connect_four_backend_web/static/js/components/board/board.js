import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';

import Row from './row';
import ColumnSelector from './column_selector';
import PlayingBoard from './playing_board';

const mapStateToProps = function(state) {
  if (state.game.id) {
    return {
      width: state.game.width
    };
  } else {
    return {

    };
  }
};

class Board extends Component {
  renderHeader() {
    const { width } = this.props;
    let colWidth = 100 / width;
    let tableHeader = [];

    for (var col = 1; col <= width; col++) {
      tableHeader.push(
        <th width={colWidth + '%'} className='text-center' key={'colHeader:' + col}>{col}</th>
      );
    }

    return (
      <tr key='tableHeaderRow'>
        {tableHeader}
      </tr>
    );
  }

  render() {
    return(
      <div>
        <table className="table table-bordered">
          <thead>
            {this.renderHeader()}
          </thead>
          <PlayingBoard />
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
