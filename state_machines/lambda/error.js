"use strict";

exports.handler = (event, context, callback) => {
  class CustomError extends Error {
    constructor(message) {
      super(message);
      this.name = CustomError.name;
    }
  }

  throw new CustomError("This is a custom error!");
};
