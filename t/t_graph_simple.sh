#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_test.sh"

WORKTREE=$(git_init graph_simple)
cd "$WORKTREE"

git_commit_tag 1-a 1-b 1-c 1-d

test_flog_graph "graph_simple" "Flog -format=%s"
