TEST_DIR=$(realpath -- "$(dirname -- "$0")")

source "$TEST_DIR/lib_dir.sh"

VIM_DIR=$(get_dir "vim/")
FLOG_DIR="${VIM_DIR}/vim-flog"
FUGITIVE_DIR="${VIM_DIR}/vim-fugitive"

install_vim() {
  echo "setting up vim..."

  remove_dir "vim/"
  create_dir "vim/vim-flog" > /dev/null

  echo "set nocompatible" > "$VIM_DIR/.vimrc"

  cd "$BASE_DIR"
  # TODO: use all directories
  # cp -rf autoload ftplugin plugin syntax "$FLOG_DIR"
  cp -rf autoload plugin "$FLOG_DIR"

  git clone -q --depth 1 "https://github.com/tpope/vim-fugitive" "$FUGITIVE_DIR"
}

run_vim_command() {
  TMP=$(create_tmp_dir "vim/")
  OUT=$TMP/_messages

  set +e
  VIMRUNTIME="$FLOG_DIR,$FUGITIVE_DIR" vim \
    -u "$VIM_DIR/.vimrc" \
    -e -s \
    -c "redir > $OUT" \
    -c "$1" \
    -c "qa!"
  STATUS=$?
  set -e

  if [[ -s "$OUT" ]]; then
    tail -n +2 "$OUT"
    echo
  fi

  return $STATUS
}
