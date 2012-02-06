# JSUT - JavaScript Unit Testing

JSUT is a universal library for unit testing JavaScript. It's goals are to be
universal, cross-platform, minimalistic, simple, and non-constraining.

# Installaton
If you run Node.js and use npm, just do:

  npm install jsut

or, to install it globally on your machine:

  npm install jsut -g 

or, if you don't use or don't want to use npm:

  curl -O jsut.zip http://nodeload.github.com/havard/jsut/zipball/master

# Running
Write a test function accepting `test` as its first argument. Be sure to call
`test.done()` on this when your test is done (i.e. at the end of the function or
after all asynchronous calls have completed).

Assuming you have a test file called `test.js`:

  jsut -b chrome test.js # Runs the tests in Chrome

  jsut -n test.js # Runs the tests in Node.js
  
  jsut -b chrome -b firefox -n test.js # Runs the tests in Chrome, Firefox, and Node.js

# Assertions
JSUT supports CommonJS style assertions.

