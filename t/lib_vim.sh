TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"

VIM_DIR=$(get_dir "vim/")
FLOG_DIR="${VIM_DIR}/vim-flog"
FUGITIVE_DIR="${VIM_DIR}/vim-fugitive"

install_vim() {
  echo "setting up vim..."

  remove_dir "vim/"
  create_dir "vim/vim-flog" > /dev/null

  echo "set nocompatible" > "$VIM_DIR/.vimrc"

  cd "$BASE_DIR"
  cp -rf autoload ftplugin plugin syntax lua "$FLOG_DIR"

  git clone -q --depth 1 "https://github.com/tpope/vim-fugitive" "$FUGITIVE_DIR"
}

run_vim_command() {
  _TMP=$(create_tmp_dir "vim/")
  _OUT=$_TMP/_messages

  set +e
  VIMRUNTIME="$FLOG_DIR,$FUGITIVE_DIR" vim \
    -u "$VIM_DIR/.vimrc" \
    -e -s \
    -c "redir > $_OUT" \
    -c "$1" \
    -c "qa!"
  STATUS=$?
  set -e

  if [ -s "$_OUT" ]; then
    tail -n +2 "$_OUT"
    echo
  fi

  return $STATUS
}
