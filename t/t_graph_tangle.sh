#!/usr/bin/env sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")
DATA_DIR=$(realpath -- "$(dirname -- "$0")/data")

source "$TEST_DIR/lib_dir.sh"
source "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_tangle)

GRAPH="[
  { 'hash': 'l', 'parents': ['k', 'reach-a'] },
  { 'hash': 'reach-a', 'parents': ['i'] },
  { 'hash': 'k', 'parents': ['j', 'octopus-a', 'octopus-b'] },
  { 'hash': 'octopus-b', 'parents': ['i'] },
  { 'hash': 'octopus-a', 'parents': ['i'] },
  { 'hash': 'j', 'parents': ['i'] },
  { 'hash': 'i', 'parents': ['h', 'side-b', 'tangle-c'] },
  { 'hash': 'tangle-c', 'parents': ['tangle-b', 'side-a'] },
  { 'hash': 'tangle-b', 'parents': ['tangle-a', 'e'] },
  { 'hash': 'tangle-a', 'parents': ['b'] },
  { 'hash': 'h', 'parents': ['g', 'side-b'] },
  { 'hash': 'side-b', 'parents': ['side-a'] },
  { 'hash': 'side-a', 'parents': ['c'] },
  { 'hash': 'g', 'parents': ['f'] },
  { 'hash': 'f', 'parents': ['e'] },
  { 'hash': 'e', 'parents': ['d'] },
  { 'hash': 'd', 'parents': ['c'] },
  { 'hash': 'c', 'parents': ['b'] },
  { 'hash': 'b', 'parents': ['a'] },
  { 'hash': 'a', 'parents': [] }
]"

CONTENT="[
  ['commit l'],
  ['commit reach-a'],
  ['commit k'],
  ['commit octopus-b'],
  ['commit octopus-a'],
  ['commit j'],
  ['commit i'],
  ['commit tangle-c'],
  ['commit tangle-b'],
  ['commit tangle-a'],
  ['commit h'],
  ['commit side-b'],
  ['commit side-a'],
  ['commit g'],
  ['commit f'],
  ['commit e'],
  ['commit d'],
  ['commit c'],
  ['commit b'],
  ['commit a']
]"

cd "$TMP"
run_vim_command "call writefile(
  flog#graph#generate($GRAPH, $CONTENT).output,
  'out'
)"

diff "out" "$DATA_DIR/graph_tangle_out"
