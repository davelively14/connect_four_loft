export const url = () => {
  if (window.location.port) {
    return window.location.protocol + '//' + window.location.hostname + ':' + window.location.port + '/';
  } else {
    return window.location.protocol + '//' + window.location.hostname + '/';
  }
};
