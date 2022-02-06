TEST_DIR=$(realpath -- "$(dirname -- "$0")")

source "$TEST_DIR/lib_dir.sh"

diff_data() {
  diff --strip-trailing-cr -- "$1" "$DATA_DIR/$2"
}
