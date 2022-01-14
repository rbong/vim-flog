#!/usr/bin/env sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")
DATA_DIR=$(realpath -- "$(dirname -- "$0")/data")

source "$TEST_DIR/lib_dir.sh"
source "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_merge)

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
  ['five'],
  ['four - Merge side'],
  ['side two'],
  ['side one'],
  ['three'],
  ['two'],
  ['one']
]"

cd "$TMP"
run_vim_command "call writefile(
  flog#graph#generate($GRAPH, $CONTENT).output,
  'out'
)"

diff "out" "$DATA_DIR/graph_merge_out"
