const handle = ({ square }, __, callback) => {
  callback(null, { text: `Received ${square} as square` });
};

exports.handle = handle;
