#
#   execute this functions with
#       1. bash test.sh functionA arg1
#       2. ./cli.sh functionA arg1
#

functionA() {
  echo "TEST A $1";
}

functionB() {
  echo "TEST B $2";
}

functionC() {
  echo "TEST B $3";
}

"$@"