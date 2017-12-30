import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as ActionCreators from '../../actions/index';

import { makeMove } from '../../helpers/api';

const mapStateToProps = (state) => {
  return {
    gameId: state.game.id,
    availCols: state.game.avail_cols,
    width: state.game.width
  };
};

const mapDispatchToProps = (dispatch) => {
  return bindActionCreators(ActionCreators, dispatch);
};

class ColumnSelector extends Component {
  drop(col) {
    const { updateState } = this.props;

    return fetch(makeMove(this.props.gameId, col), {
      method: 'put'
    }).then(
      function(response) {
        return response.text();
      }
    ).then(
      function(text) {
        updateState(JSON.parse(text));
      }
    );
  }

  renderButtons() {
    const {availCols, width} = this.props;
    let buttonMarkup = [];

    for (var x = 1; x <= width; x++) {

      if (availCols.includes(x)) {
        buttonMarkup.push(
          <td key={'col:' + x} className="text-center">
            <button onClick={this.drop.bind(this, x)} className="btn btn-primary" key={'select-col:' + x}>Add</button>
          </td>
        );
      } else {
        buttonMarkup.push(<td key={'col:' + x}></td>);
      }
    }

    return buttonMarkup;
  }

  render() {
    return(
      <tfoot>
        <tr>
          {this.renderButtons()}
        </tr>
      </tfoot>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSelector);
