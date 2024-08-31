TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_vim.sh"

# Run a ":Flog" command and test the output.
# Tests with defaults, extended chars, and highlights.
# Compares with output data in "t/data".
function test_flog_graph() {
  NAME="$1"
  CMD="$2"
  CLEANUP="$3"

  TMP=$(create_tmp_dir "$NAME")

  # Test defaults
  VIM_OUT="$TMP/basic_out"
  run_vim_command <<EOF
$CMD
redir! >/dev/null | silent w $VIM_OUT | redir END
EOF
  diff_data "$VIM_OUT" "${NAME}_out"

  if [ "$CLEANUP" != "" ]; then
    $CLEANUP
  fi

  # Test extended chars
  VIM_OUT="$TMP/extended_out"
  run_vim_command <<EOF
let g:flog_enable_extended_chars = 1
$CMD
redir! >/dev/null | silent w $VIM_OUT | redir END
EOF
  diff_data "$VIM_OUT" "${NAME}_extended_out"

  if [ "$CLEANUP" != "" ]; then
    $CLEANUP
  fi

  if [ "$NVIM" != "" -a "$NVIM" != "false" ]; then
    # Test highlights
    VIM_OUT="$TMP/hl_out"
    run_vim_command <<EOF
$CMD
call flog#test#ShowNvimBufHl()
redir! >/dev/null | silent w $VIM_OUT | redir END
EOF
    diff_data "$VIM_OUT" "${NAME}_hl_out"

    if [ "$CLEANUP" != "" ]; then
      $CLEANUP
    fi

    # Test extended chars/highglights
    VIM_OUT="$TMP/extended_hl_out"
    run_vim_command <<EOF
let g:flog_enable_extended_chars = 1
$CMD
call flog#test#ShowNvimBufHl()
redir! >/dev/null | silent w $VIM_OUT | redir END
EOF
    diff_data "$VIM_OUT" "${NAME}_extended_hl_out"

    if [ "$CLEANUP" != "" ]; then
      $CLEANUP
    fi
  fi
}
