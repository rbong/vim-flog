#!/usr/bin/env sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")
DATA_DIR=$(realpath -- "$(dirname -- "$0")/data")

source "$TEST_DIR/lib_dir.sh"
source "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_merge_multiline)

GRAPH="[
  { 'hash': 'e', 'parents': ['d'] },
  { 'hash': 'd', 'parents': ['c', 'side-b'] },
  { 'hash': 'side-b', 'parents': ['side-a'] },
  { 'hash': 'side-a', 'parents': ['b'] },
  { 'hash': 'c', 'parents': ['b'] },
  { 'hash': 'b', 'parents': ['a'] },
  { 'hash': 'a', 'parents': [] },
]"

CONTENT="[
  ['five line 1', 'five line 2', 'five line 3', 'five line 4'],
  ['four - Merge side', 'four line 2', 'four line 3'],
  ['side two line 1', 'side two line 2'],
  ['side one line 1', 'side one line 2'],
  ['three line 1', 'three line 2'],
  ['two line 1', 'two line 2'],
  ['one line 1', 'one line 2']
]"

cd "$TMP"
run_vim_command "call writefile(
  flog#graph#generate($GRAPH, $CONTENT).output,
  'out'
)"

diff "out" "$DATA_DIR/graph_merge_multiline_out"
