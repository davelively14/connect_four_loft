import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
// import * as ActionCreators from '../actions/index';

const mapStateToProps = function(_state) {
  return {

  };
};

const mapDispatchToProps = function(_dispatch) {
  // return bindActionCreators(ActionCreators, dispatch);
  return {

  };
};

class Landing extends Component {
  render() {
    return(
      <div>
        <div className="jumbotron">
          <h2>Welcome to Connect Four</h2>
          <p className="lead">A productive web framework that<br />does not compromise speed and maintainability.</p>
        </div>

        <div className="row marketing">
          <div className="col-lg-6">
            <h4>Resources</h4>
            <ul>
              <li>
                <a href="http://phoenixframework.org/docs/overview">Guides</a>
              </li>
              <li>
                <a href="https://hexdocs.pm/phoenix">Docs</a>
              </li>
              <li>
                <a href="https://github.com/phoenixframework/phoenix">Source</a>
              </li>
            </ul>
          </div>

          <div className="col-lg-6">
            <h4>Help</h4>
            <ul>
              <li>
                <a href="http://groups.google.com/group/phoenix-talk">Mailing list</a>
              </li>
              <li>
                <a href="http://webchat.freenode.net/?channels=elixir-lang">#elixir-lang on freenode IRC</a>
              </li>
              <li>
                <a href="https://twitter.com/elixirphoenix">@elixirphoenix</a>
              </li>
            </ul>
          </div>
        </div>

      </div>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Landing);
