TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"

diff_data() {
  diff --color --strip-trailing-cr -- "$1" "$DATA_DIR/$2"
}
