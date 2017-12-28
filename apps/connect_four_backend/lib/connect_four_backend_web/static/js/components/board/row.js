import React from 'react';

function contains(arr, item) {
  return arr.some(function(partial) {
    return JSON.stringify(partial) === JSON.stringify(item);
  });
}

const Row = (row, width, board) => {
  var rowMarkup = [];

  for (var x = 1; x <= width; x++) {
    switch (true) {
      case contains(board.player_1, [x, row]):
        rowMarkup.push(<td className="danger" key={[x, row]}></td>);
        break;
      case contains(board.player_2, [x, row]):
        rowMarkup.push(<td className="warning" key={[x, row]}></td>);
        break;
      default:
        rowMarkup.push(<td key={[x, row]}></td>);
    }
  }

  return (
    <tr key={'row: ' + row}>
      {rowMarkup}
    </tr>
  );
};

export default Row;
