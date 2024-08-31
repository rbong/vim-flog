TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"

_diff_data() {
  diff --color --strip-trailing-cr -- "$1" "$DATA_DIR/$2"
}

diff_data() {
  if [ "$UPDATE_SNAPSHOTS" = "true" ]; then
    if ! _diff_data "$1" "$2" &>/dev/null; then
      echo "WARNING: Updating snapshot: $2"
      cp "$1" "$DATA_DIR/$2"
    fi
  fi

  _diff_data "$1" "$2"
  echo "Snapshot matches: $2"
}
