var util = require('util'),
    fs = require('fs');

var cp = function(from, to, cb) {
  var is = fs.createReadStream(from),
      os = fs.createWriteStream(to);

  os.once('open', function(fd) {
    util.pump(is, os, cb);
  });
  
}

var rm = function(file, cb) {

}

if (process.platform !== 'win32') {
  cp('jsut.sh', 'jsut.bat');
}
