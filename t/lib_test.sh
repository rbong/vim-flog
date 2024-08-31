TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_vim.sh"

# Run a ":Flog" command and test the output.
# Tests with defaults and extended chars.
# Compares with output data in "t/data".
function test_flog_graph() {
  NAME="$1"
  CMD="$2"

  TMP=$(create_tmp_dir "$NAME")

  # Test defaults
  VIM_OUT="$TMP/basic_out"
  run_vim_command <<EOF
$CMD
silent w $VIM_OUT
EOF
  diff_data "$VIM_OUT" "${NAME}_out"

  # Test extended chars
  VIM_OUT="$TMP/extended_out"
  run_vim_command <<EOF
let g:flog_enable_extended_chars = 1
$CMD
silent w $VIM_OUT
EOF
  diff_data "$VIM_OUT" "${NAME}_extended_out"
}
