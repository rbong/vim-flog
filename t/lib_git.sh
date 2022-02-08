TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"

git_init() {
  _WORKTREE=$(create_tmp_dir "repo/$1")
  _GIT_DIR="$_WORKTREE/.git"
  git --git-dir="$_GIT_DIR" init -q -b main
  git --git-dir="$_GIT_DIR" config user.email flog@test.com
  git --git-dir="$_GIT_DIR" config user.name flog
  echo $_WORKTREE
}

git_checkout() {
  git checkout -q "$@"
}

git_commit() {
  git commit -q --allow-empty "$@"
}

git_merge() {
  git merge -q --no-edit --no-ff "$@"
}

git_tag() {
  git tag "$@"
}

# Create and tag multiple commits
git_commit_tag() {
  for commit in $@; do
    git_commit -m "$commit"
    git_tag "$commit"
  done
}
