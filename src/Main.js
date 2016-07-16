var fs = require('fs');
var gm = require('gm').subClass({imageMagick: true});

exports.getArgs = function () {
  if (process.argv.length < 5) {
    throw new Error('not enough args supplied: need two args for orig (file) and dest (dir) filepaths and filetype');
  }
  return {
    orig: process.argv[2],
    dest: process.argv[3],
    filetype: process.argv[4]
  }
}

exports.convert = function (callback) {
  return function (options) {
    return function () {
      var orig = options.orig;
      var path = options.path;
      var length = options.length;
      var filetype = options.filetype;
      var newPath = path + length + '.' + filetype;

      gm(orig)
      .resize(length, length, '^')
      .gravity('Center')
      .extent(length, length)
      .write(newPath, function (err) {
        if (err) {
          throw new Error(err);
        } else {
          callback(newPath)();
        }
      });
    }
  }
}
