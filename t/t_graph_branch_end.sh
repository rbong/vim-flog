#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_test.sh"

WORKTREE=$(git_init graph_branch_end)
cd "$WORKTREE"

git_commit_tag 1-a 1-b

git_checkout 1-a
git_commit_tag 4-a

sleep 1

git_checkout 1-a
git_commit_tag 3-a

git_checkout 1-b
git_commit_tag 1-c
git_merge -m 2-a 3-a 4-a
git_tag 2-a

git_checkout 4-a
git_commit_tag 4-b

git_checkout 3-a
git_commit_tag 3-b

git_checkout 2-a
git_commit_tag 2-b

git_checkout 1-c
git_merge -m 1-e 2-b 3-b 4-b

test_flog_graph "graph_branch_end" "Flog -order=date -format=%s"
