TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"

git_init() {
  _WORKTREE=$(create_tmp_dir "repo/$1")
  git --git-dir="$_WORKTREE/.git" init -q -b main
  echo $_WORKTREE
}

git_checkout() {
  git checkout -q "$@"
}

git_commit() {
  git commit -q --allow-empty "$@"
}

git_merge() {
  git merge -q --no-edit "$@"
}

git_tag() {
  git tag "$@"
}
