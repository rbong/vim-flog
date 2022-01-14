TEST_DIR=$(realpath -- "$(dirname -- "$0")")

source "$TEST_DIR/lib_dir.sh"

git_init() {
  GIT_DIR=$(create_tmp_dir "repo/$1")
  git --git-dir="$GIT_DIR" init -q -b main
  echo $GIT_DIR
}

git_checkout() {
  git checkout $@
}

git_commit() {
  git commit -q --allow-empty $@
}

git_merge() {
  git merge -q --no-edit $@
}
