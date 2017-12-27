import React, { Component } from 'react';
import { Field, reduxForm } from 'redux-form';
import { Link } from 'react-router';
import { renderFieldAndLabel, renderFieldAndLabelFocus } from '../../helpers/fields';

class NewGameForm extends Component {
  render() {
    const { handleSubmit } = this.props;

    return(
      <form onSubmit={handleSubmit}>
        <Field name="player1" type="text" component={renderFieldAndLabel} placeholder="First Player Name" autoFocus />
        <Field name="player2" type="text" component={renderFieldAndLabel} placeholder="Second Player Name" />

        <button type="submit" className="btn btn-primary">Submit</button>
        <Link to="/" className="btn btn-danger pull-right">Cancel</Link>
      </form>
    );
  }
}

NewGameForm = reduxForm({
  form: 'newGameForm'
})(NewGameForm);

export default NewGameForm;
