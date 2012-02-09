var passes = function(test) {
  test.done();
}

var fails = function(test) {
  assert.ok(false);
}

var passesSynchronously = function() {
}

if(typeof(exports) !== 'undefined') {
  exports.passes = passes;
  exports.fails = fails;
  exports.indeterminate = indeterminate;
}
