TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_print.sh"

git_init() {
  _WORKTREE=$(create_tmp_dir "repo/$1")
  _GIT_DIR="$_WORKTREE/.git"
  git --git-dir="$_GIT_DIR" init -q -b main
  git --git-dir="$_GIT_DIR" config user.email flog@test.com
  git --git-dir="$_GIT_DIR" config user.name flog
  echo $_WORKTREE
}

git_checkout() {
  print_debug "Checking out: $@"
  git checkout -q "$@"
}

git_commit() {
  print_debug "Commiting: $@"
  git commit -q --allow-empty "$@"
}

git_merge() {
  print_debug "Merging: $@"
  git merge -q --no-edit --no-ff --strategy=ours "$@"
}

git_tag() {
  print_debug "Tagging: $@"
  git tag "$@"
}

# Create and tag multiple commits
git_commit_tag() {
  for commit in $@; do
    git_commit -m "$commit"
    git_tag "$commit"
  done
}
