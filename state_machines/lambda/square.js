const handler = ({ numberParam }, _, callback) => {
  callback(null, { square: Math.sqrt(numberParam) });
};

exports.handler = handler;
