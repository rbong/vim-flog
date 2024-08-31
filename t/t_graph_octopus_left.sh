#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_test.sh"

WORKTREE=$(git_init graph_merge_octopus_left)
cd "$WORKTREE"

git_commit_tag 1-a 1-b

git_checkout 1-a
git_commit_tag 2-a

git_checkout 1-a
git_commit_tag 3-a

git_checkout 1-a
git_commit_tag 4-a

git_checkout 1-b
git_merge -m 2-b 2-a 3-a 4-a
git_tag 2-b

git_checkout 1-b
git_commit_tag 1-c

test_flog_graph "graph_octopus_left" "Flog -format=%s -rev=1-c -rev=2-b"
