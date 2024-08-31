#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_test.sh"

WORKTREE=$(git_init graph_merge_tangle)
cd "$WORKTREE"

git_commit_tag 1-a 1-b 1-c 1-d 1-e

git_checkout 1-b
git_commit_tag 2-a

git_checkout 1-c
git_commit_tag 3-a

git_checkout 1-e
git_commit_tag 1-f

git_checkout 2-a
git_merge -m 2-b 1-e
git_tag 2-b

git_checkout 3-a
git_commit_tag 3-b

git_checkout 1-f
git_commit_tag 1-g

git_checkout 2-b
git_merge -m 2-c 3-a
git_tag 2-c

git_checkout 1-g
git_merge -m 1-h 3-b
git_merge -m 1-i 2-c
git_tag 1-i

git_checkout 1-i
git_commit_tag 4-a

git_checkout 1-i
git_commit_tag 3-c

git_checkout 1-i
git_commit_tag 1-j

git_checkout 1-i
git_commit_tag 2-d

git_checkout 1-j
git_merge -m 1-k 3-c 4-a
git_merge -m 1-l 2-d

test_flog_graph "graph_tangle" "Flog -order=date -format=%s"
test_flog_graph "graph_tangle_range" "Flog -format=%s -rev=2-c..2-d"
