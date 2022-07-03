#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_print.sh"
. "$TEST_DIR/lib_vim.sh"

# Setup
cd "$BASE_DIR"
install_vim

# Get args
if [ "$1" != "" ]; then
  TESTS="$TEST_DIR/$1"
else
  TESTS=$(ls "$TEST_DIR"/t_*)
fi

# Run tests
FAILED_TESTS=0
for TEST in $TESTS; do
  # Reset
  cd "$BASE_DIR"
  remove_tmp_dirs

  # Run the test
  print_title "${TEST}"
  set +e
  "${TEST}"
  RESULT=$?
  set -e

  # Process result
  if [ $RESULT -eq 0 ]; then
    print_success
  else
    print_fail
    FAILED_TESTS=$(expr "$FAILED_TESTS" + 1)
  fi
done

if [ $FAILED_TESTS -gt 0 ]; then
  exit 1
fi
