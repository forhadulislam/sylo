#!/bin/bash
#
#   execute this functions with
#       1. bash test.sh functionA arg1
#       2. ./cli.sh functionA arg1
#

functionA() {
  echo "TEST A $1";
  echo "This is $NAME";
  export NAME="$NAME";
  #printenv
}

functionB() {
  echo "TEST B $2";
}

functionC() {
  echo "TEST B $3";
}

# Check if the function provided exists
# Can get rid of this block with a "$@"
if declare -f "$1" > /dev/null
then
  # call arguments verbatim
  "$@"
else
  # Show a helpful error
    if [[ -z "$1" ]]; then
        echo "no function provided! please provide a function name to execute"
    elif [[ -n "$1" ]]; then
        echo "'$1' is not a known function name" >&2
    fi  
  exit 1
fi