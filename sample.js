var passes = function(test) {
  test.done();
}

var fails = function(test) {
  test.ok(false);
}

var indeterminate = function() {
}

if(typeof(exports) !== 'undefined') {
  exports.passes = passes;
  exports.fails = fails;
  exports.indeterminate = indeterminate;
}
