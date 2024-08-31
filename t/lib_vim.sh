TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"

export VIM_DIR=$(get_dir "vim/")
export FLOG_DIR="${VIM_DIR}/vim-flog"
export FUGITIVE_DIR="${VIM_DIR}/vim-fugitive"

export VIMRC="$VIM_DIR/.vimrc"

install_vim() {
  echo "setting up vim..."

  remove_dir "vim/"
  create_dir "vim/vim-flog" > /dev/null

  cd "$BASE_DIR"
  cp -rf autoload ftplugin plugin syntax lua "$FLOG_DIR"

  git clone -q --depth 1 "https://github.com/tpope/vim-fugitive" "$FUGITIVE_DIR"
}

run_vim_command() {
  _TMP=$(create_tmp_dir "vim/")

  _SCRIPT=$_TMP/_script.vim
  _OUT="$_TMP/_out"

  cat > "$_SCRIPT"

  cat <<EOF > "$VIMRC"
set nocompatible
set lines=200
filetype plugin indent on
exec 'set rtp+=' . fnameescape("$FLOG_DIR")
exec 'set rtp+=' . fnameescape("$FUGITIVE_DIR")
EOF

  _VIM=vim
  if [ "$NVIM" = "true" ]; then
    _VIM=nvim
  fi

  set +e
  $_VIM \
    -u "$VIMRC" \
    -e \
    -c "redir > $_OUT" \
    -S "$_SCRIPT" \
    -c "qa!"
  STATUS=$?
  set -e

  if [ -s "$_OUT" ]; then
    tail -n +2 "$_OUT"
    echo
  fi

  rm -f "$_OUT"

  return $STATUS
}
