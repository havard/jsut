jsut = {
  BrowserReporter: {
    runStarted: function() {
      var list = document.createElement('ul');
      document.body.appendChild(list);
      return { list: list };
    },
    runEnded: function(runToken) {
    },
    testStarted: function(runToken, name) {
        var item = document.createElement('li');
        item.innerHTML = name + '... ';
        runToken.list.appendChild(item);
        return { item: item };
    },
    testEnded: function(testToken, passed) {
      if(passed) {
        testToken.item.innerHTML += 'passed.';
        testToken.item.style.color = '#0f0';
      }
      else if(passed == null) {
        testToken.item.innerHTML += 'inconclusive.';
        testToken.item.style.color = '#0ff';
      }
      else {
        testToken.item.innerHTML += 'failed.';
        testToken.item.style.color = '#f00';
      }
    },
    error: function(message) {
    }
  },

  ConsoleReporter: {
    runStarted: function() {
      console.log('Run started.');
    },
    runEnded: function(runToken) {
      console.log('All tests completed.');
    },
    testStarted: function(runToken, name) {
      return { name: name };
    },
    testEnded: function(testToken, passed) {
      if(passed) {
        console.log('  ' + testToken.name + '... passed.');
      }
      else if(passed == null) {
        console.log('  ' + testToken.name + '... inconclusive.');
      }
      else {
        console.log('  ' + testToken.name + '... failed.');
      }
    },
    error: function(message) {
      console.log('Error: ' + message);
    }
  },

  runner: {
    tests: {},
    initials: {},
    enumerables: [],
    reporter: null,

    init: function() {
      if(typeof(window) !== 'undefined') {
        this.reporter = jsut.BrowserReporter;
        this.enumerables.push(window);
        for(var i in window) {
          this.initials[i] = true;
        }
      }
      else {
        this.reporter = jsut.ConsoleReporter;
      }

      if(typeof(process) !== 'undefined') {
        var args = process.argv.slice(2);
        for(var a in args) {
          var file = args[a];
          var moduleName = file.substring(0, file.lastIndexOf('.js')).replace(/^\s\s*/, '').replace(/\s\s*$/, '');;
          try {
            var module = require('./' + moduleName);
            this.enumerables.push(module);
          }
          catch(err) {
            this.reporter.error('Unable to load file ' + file + ' (as module ' + moduleName + ').');
          }
        }
      }
    },

    enumerate: function() {
      for(var i in this.enumerables) {
        var enumerable = this.enumerables[i];
        for(var j in enumerable) {
          var type = null;
          try {
            type = typeof(enumerable[j])
          }
          catch(err) {
            // Ignore type lookup errors (Firefox internals are particularly lousy at this)
          }
          if(type === 'function' && !this.initials[j]) {
            this.tests[j] = enumerable[j];
          }
        }
      }
    },

    run: function() {
      var runner = this;
      var runToken = runner.reporter.runStarted();
      for(var testName in runner.tests) {
        var test = runner.tests[testName];
        var token = runner.reporter.testStarted(runToken, testName);
        try {
          var timeoutFunction = setTimeout(function() { runner.reporter.testEnded(token, null); }, 10000);
          test({ done: function() { clearTimeout(timeoutFunction); runner.reporter.testEnded(token, true); }});
        }
        catch(err) {
          runner.reporter.testEnded(token, false);
        }
      }
      runner.reporter.runEnded();
    }
  }
};

jsut.runner.init();

if(typeof(process) !== 'undefined') {
  jsut.runner.enumerate();
  jsut.runner.run();
}
