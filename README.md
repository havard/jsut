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
    
or, [just download the JSUT zip with your browser.](http://nodeload.github.com/havard/jsut/zipball/master)

# Writing and running tests
Write a test function. If your test function does asnychronous calls, accept a `test` object
as its first argument, and be sure to call `test.done()` on this when your test is done 
(i.e. after all asynchronous calls have completed).

Assuming you have tests in a test file called `test.js`:

    jsut -b chrome test.js # Runs the tests in Chrome

    jsut -n test.js # Runs the tests in Node.js
  
    jsut -b firefox -b opera -n test.js # Runs the tests in Firefox, Opera, and Node.js

# Working with test dependencies
JSUT allows for simple specification of additional files or folders that are required by your tests:

    jsut -b ie -d lib test.js # test.js depends on the lib folder

# Assertions
JSUT supports CommonJS style assertions.

