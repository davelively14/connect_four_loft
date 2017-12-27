import React, { Component } from 'react';
import { Field, reduxForm } from 'redux-form';
import { Link } from 'react-router';
import { renderFieldAndLabelFocus } from '../../helpers/fields';

class NewGameCPUForm extends Component {
  render() {
    const { handleSubmit } = this.props;

    return(
      <form onSubmit={handleSubmit}>
        <Field name="player1" type="text" component={renderFieldAndLabelFocus} placeholder="First Player Name" />
        <label>Set Difficulty</label>&nbsp;&nbsp;
        <Field name="difficulty" component="select">
          <option></option>
          <option value="easy">Easy</option>
        </Field>
        <br></br>
        <br></br>

        <button type="submit" className="btn btn-primary">Submit</button>
        <Link to="/" className="btn btn-danger pull-right">Cancel</Link>
      </form>
    );
  }
}

NewGameCPUForm = reduxForm({
  form: 'newGameForm'
})(NewGameCPUForm);

export default NewGameCPUForm;
