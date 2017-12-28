import React from 'react';

export const renderFieldAndLabel = ({input, placeholder, type, meta: {touched, error}}) => (
  <div className="form-group">
    <div>
      <label>{placeholder}</label>
      <input {...input} placeholder={placeholder} type={type} className="form-control" />
      {touched && error && <span>{error}</span>}
    </div>
  </div>
);

export const renderFieldAndLabelFocus = ({input, placeholder, type, meta: {touched, error}}) => (
  <div className="form-group">
    <div>
      <label>{placeholder}</label>
      <input {...input} placeholder={placeholder} type={type} className="form-control" autoFocus />
      {touched && error && <span>{error}</span>}
    </div>
  </div>
);
