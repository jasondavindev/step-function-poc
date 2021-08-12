const handler = ({ square }, __, callback) => {
  callback(null, { text: `Received ${square} as square`, numberParam: square });
};

exports.handler = handler;
