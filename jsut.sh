#!/bin/sh

# Find common parent directory path for a pair of paths.
# Call with two pathnames as args, e.g.
# commondirpart foo/bar foo/baz/bat -> result="foo/"
# The result is either empty or ends with "/".

JSUTCOMMAND=$0

CWD=$(pwd)
cd $(dirname $JSUTCOMMAND)
JSUTCOMMAND=$(basename $JSUTCOMMAND)

# Iterate down a (possible) chain of symlinks
while [ -L "$JSUTCOMMAND" ]
do
    JSUTCOMMAND=$(readlink $JSUTCOMMAND)
    cd $(dirname $JSUTCOMMAND)
    JSUTCOMMAND=$(basename $JSUTCOMMAND)
done

# Compute the canonicalized name by finding the physical path 
# for the directory we're in and appending the target file.
JSUTDIR=$(pwd -P)
cd $CWD

commondirpart () {
   result=""
   while test ${#1} -gt 0 -a ${#2} -gt 0; do
      if test "${1%${1#?}}" != "${2%${2#?}}"; then   # First characters the same?
         break                                       # No, we're done comparing.
      fi
      result="$result${1%${1#?}}"                    # Yes, append to result.
      set -- "${1#?}" "${2#?}"                       # Chop first char off both strings.
   done
   case "$result" in
   (""|*/) ;;
   (*)     result="${result%/*}/";;
   esac
}

# Turn foo/bar/baz into ../../..
#
dir2dotdot () {
   OLDIFS="$IFS" IFS="/" result=""
   for dir in $1; do
      result="$result../"
   done
   result="${result%/}"
   IFS="$OLDIFS"
}

# Call with FROM TO args.
relativepath () {
   case "$1" in
   (*//*|*/./*|*/../*|*?/|*/.|*/..)
      printf '%s\n' "'$1' not canonical"; exit 1;;
   (/*)
      from="${1#?}";;
   (*)
      printf '%s\n' "'$1' not absolute"; exit 1;;
   esac
   case "$2" in
   (*//*|*/./*|*/../*|*?/|*/.|*/..)
      printf '%s\n' "'$2' not canonical"; exit 1;;
   (/*)
      to="${2#?}";;
   (*)
      printf '%s\n' "'$2' not absolute"; exit 1;;
   esac

   case "$to" in
   ("$from")   # Identical directories.
      result=".";;
   ("$from"/*) # From /x to /x/foo/bar -> foo/bar
      result="${to##$from/}";;
   ("")        # From /foo/bar to / -> ../..
      dir2dotdot "$from";;
   (*)
      case "$from" in
      ("$to"/*)       # From /x/foo/bar to /x -> ../..
         dir2dotdot "${from##$to/}";;
      (*)             # Everything else.
         commondirpart "$from" "$to"
         common="$result"
         dir2dotdot "${from#$common}"
         result="$result/${to#$common}"
      esac
      ;;
   esac
}

set -f # noglob

# Display usage 
usage() {
  cat <<EOF
Usage: $0 [ -b <browser> ]* [ -d <path> ]* [ -nh ] <path> [<path>]*
EOF
}

# Display usage and help
help() {
  usage
  cat <<EOF
JSUT is JavaScript Unit Testing. It supports running tests across browsers and
in Node.js keeping its influence on how you write unit tests as small as
possible.

Options:
  -b <browser>  Run test in the specified browser. Can be repeated to specify
                multiple browsers.
  -d <path>     Add the given path to the test environment as a dependency.
                Any tests in any files in the dependency path will be ignored.
  -n            Run tests in Node.js. Requires Node.js to be present in the 
                PATH of the local machine.
  -t <timeout>  Specify how long to wait (in seconds) before terminating the
                test run. This is useful if tests are waiting for asynchronous
                operations to complete. 
                The default timeout is $TIMEOUT seconds.
  -h            Print this help text and exit.

Writing a unit test is as simple as writing a single argument function. Your
test functions will be passed a test object as their first argument. When a
test is done, it should call the done() function on this test object to signal
that it has completed successfully. To signal failure the test should either
contain a failing assertion, throw an exception, or call fail() on the test
object, optionally passing an error message as the first argument.

JSUT supports assertions in the style of the Node.js assert module. Please see
the Node.js site at http://nodejs.org for documentation on its assert module.
EOF
}

# Run tests in Node.js
nodejs() {
  cd $TMPDIR
  node __jsut.js $NODESCRIPTS
}

# Run tests in Firefox
jsut_firefox() {
  open -a Firefox $JSUTURL
}

jsut_ff() {
  jsut_firefox
}

jsut_f() {
  jsut_firefox
}

# Run tests in Opera
jsut_opera() {
  open -a Opera $JSUTURL
}

jsut_o() {
  jsut_opera
}

# Run tests in Safari
jsut_safari() {
  open -a Safari $JSUTURL
}

jsut_s() {
  jsut_safari
}

# Run tests in Chrome
jsut_chrome() {
  open -a Google\ Chrome $JSUTURL
}

jsut_c() {
  jsut_chrome
}

# Run tests in Internet Explorer
jsut_internetexplorer() {
  echo "Microsoft Internet Explorer is not supported on this platform."
}

jsut_ie() {
  jsut_internetexplorer
}

jsut_i() {
  jsut_internetexplorer
}

# Parse and read command line options and arguments
BROWSERINDEX=0
DEPENDENCYINDEX=0
FILEINDEX=0

while [ $# -gt 0 ]; do
  case $1 in
    -*) 
      while getopts "b:d:hn" OPTION
      do
        case $OPTION in 
          b)
            case $OPTARG in
              firefox|ff|f)
                ;;
              opera|o)
                ;;
              safari|s)
                ;;
              chrome|c)
                ;;
              internetexplorer|ie|i)
                ;;
              *)
                echo "Error: Unsupported browser \"$OPTARG\""
                usage
                exit 1
                ;;
            esac

            eval BROWSERS$BROWSERINDEX=$OPTARG
            BROWSERINDEX=$((BROWSERINDEX + 1))
            ;;
          d)
            if [ ! -f $OPTARG ] && [ ! -d $OPTARG ]; then
              echo "Error: Dependency $OPTARG is not a file or directory."
              usage
              exit 1
            fi
            eval DEPENDENCY$DEPENDENCYINDEX=$OPTARG
            DEPENDENCYINDEX=$((DEPENDENCYINDEX + 1))
            ;;
          h)
            help
            exit 0
            ;;
          n)
            NODE=true
            ;;
          *)
            usage
            exit 1
            ;;
        esac
      done
      while [ $OPTIND -gt 1 ]; do
        shift
        OPTIND=$((OPTIND - 1))
      done
      ;;
    *) 
      eval FILE$FILEINDEX=$1
      FILEINDEX=$((FILEINDEX + 1))
      shift
      ;;
  esac
done

# Validate options and arguments
if [ -z $BROWSERS0 ] && [ -z $NODE ]; then
  echo "Error: You must specify one of -b <browser> or -n to run tests."
  usage
  exit 1
elif [ -z $FILE0 ]; then
  echo "Error: You must specify at least one test file."
  usage
  exit 1
fi

# Create temporary test suite folder
TMPDIR=/tmp/jsut.$$
mkdir -p $TMPDIR

# Read dependencies and load into test suite folder
CURRENTDEPENDENCY=0
while [ ! -z $(eval echo  "\${DEPENDENCY${CURRENTDEPENDENCY}}") ]; do
  QUALIFIEDDEPENDENCY=$(eval echo \$DEPENDENCY${CURRENTDEPENDENCY})

  if [ ! -f $QUALIFIEDDEPENDENCY ] && [ ! -d $QUALIFIEDDEPENDENCY ]; then
    echo "Error: Dependency path $QUALIFIEDDEPENDENCY is not a file or directory."
    exit 1
  fi

  if [ "$(pwd -P $QUALIFIEDDEPENDENCY)" = "$(dirname $QUALIFIEDDEPENDENCY)" ]; then
    relativepath $PWD $QUALIFIEDDEPENDENCY
    QUALIFIEDDEPENDENCY=$result
  fi

  mkdir -p $TMPDIR/$QUALIFIEDDEPENDENCYDIR
  cp -r $QUALIFIEDDEPENDENCY $TMPDIR
  if [ -f $QUALIFIEDDEPENDENCY ] && [ "${QUALIFIEDDEPENDENCY##*.}" = "js" ]; then
    BROWSERSCRIPTS="${BROWSERSCRIPTS}\\<script\\ type=\\\"text\\/javascript\\\"\\ src=\\\"${QUALIFIEDDEPENDENCY}\\\"\\>\\<\\/script\\>"
  elif [ -d $QUALIFIEDDEPENDENCY ]; then
    for TESTDEPENDENCY in $(ls $QUALIFIEDDEPENDENCY); do
      if [ "${TESTDEPENDENCY##*.}" = "js" ]; then
        BROWSERSCRIPTS="${BROWSERSCRIPTS}\\<script\\ type=\\\"text\\/javascript\\\"\\ src=\\\"${QUALIFIEDDEPENDENCY}\\/${TESTDEPENDENCY}\\\"\\>\\<\\/script\\>"
      fi
    done
  fi
  CURRENTDEPENDENCY=$((CURRENTDEPENDENCY+1))
done

# Read test files and load into test suite folder
CURRENTFILE=0
while [ ! -z $(eval echo "\${FILE${CURRENTFILE}}") ]; do
  QUALIFIEDFILE=$(eval echo \$FILE${CURRENTFILE})

  if [ ! -f $QUALIFIEDFILE ] && [ ! -d $QUALIFIEDFILE ]; then
    echo "Error: Test path $QUALIFIEDFILE is not a file or directory."
    exit 1
  fi
  if [ "$(pwd -P $QUALIFIEDFILE)" = "$(dirname $QUALIFIEDFILE)" ]; then
    relativepath $PWD $QUALIFIEDFILE
    QUALIFIEDFILE=$result
  fi
  QUALIFIEDFILEDIR=$(dirname $QUALIFIEDFILE)
  mkdir -p $TMPDIR/$QUALIFIEDFILEDIR
  cp -r $QUALIFIEDFILE $TMPDIR
  if [ -f $QUALIFIEDFILE ]; then
    BROWSERSCRIPTS="${BROWSERSCRIPTS}\\<script\\ type=\\\"text\\/javascript\\\"\\ src=\\\"${QUALIFIEDFILE}\\\"\\>\\<\\/script\\>"
  else 
    for TESTFILE in $(ls $QUALIFIEDFILE); do
      if [ "${TESTFILE##*.}" = "js" ]; then
        BROWSERSCRIPTS="${BROWSERSCRIPTS}\\<script\\ type=\\\"text\\/javascript\\\"\\ src=\\\"${QUALIFIEDFILE}\\/${TESTFILE}\\\"\\>\\<\\/script\\>"
      fi
    done
  fi
  NODESCRIPTS="${NODESCRIPTS} ${QUALIFIEDFILE}"
  CURRENTFILE=$((CURRENTFILE+1))
done

# Prepare JSUT browser test and scripts
sed s/SCRIPTS/"$BROWSERSCRIPTS"/ $JSUTDIR/jsut.html > $TMPDIR/jsut.html
cp $JSUTDIR/assert.js $TMPDIR/__assert.js
cp $JSUTDIR/jsut.js $TMPDIR/__jsut.js
JSUTURL=file://$TMPDIR/jsut.html
cd $TMPDIR

# Run Node if asked to
if [ $NODE ]; then
  nodejs
fi

# Run browsers if asked to
CURRENTBROWSER=0
while [ ! -z $(eval echo "\${BROWSERS${CURRENTBROWSER}}") ]; do
  eval jsut_\$BROWSERS${CURRENTBROWSER}
  CURRENTBROWSER=$((CURRENTBROWSER+1))
done

