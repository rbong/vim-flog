#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_test.sh"

WORKTREE=$(git_init graph_merge_octopus_crossover)
cd "$WORKTREE"

git_commit_tag 1-a

git_checkout 1-a
git_commit_tag 2-a

git_checkout 1-a
git_commit_tag 3-a

git_checkout 1-a
git_commit_tag 4-a

git_checkout 1-a
git_commit_tag 5-a

git_checkout 2-a
git_merge -m 2-b 3-a 4-a 5-a
git_tag 2-b

git_checkout 1-a
git_commit_tag 1-b

test_flog_graph "graph_octopus_crossover" "Flog -format=%s -rev=1-b -rev=2-b"
