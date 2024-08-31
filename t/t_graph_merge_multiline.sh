#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_test.sh"

WORKTREE=$(git_init graph_merge_multiline)
cd "$WORKTREE"

git_commit_tag 1-a 1-b 1-c

git_checkout 1-b
git_commit_tag 2-a 2-b

git_checkout 1-c
git_merge -m 1-d 2-b
git_commit_tag 1-e

test_flog_graph "graph_merge_multiline" "Flog -format=%s%n%s"
test_flog_graph "graph_merge_multiline_hidden" "exec 'Flog -format=%s%n%s' | redir! >/dev/null | exec 'normal <' | redir END"
