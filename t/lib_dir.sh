export TEST_DIR=$(realpath -- "$(dirname -- "$0")")
export BASE_DIR=$(realpath -- "$(dirname -- "$0")/..")
export DATA_DIR=$(realpath -- "$(dirname -- "$0")/data")

get_dir() {
  echo "$BASE_DIR/.test/$1"
}

get_tmp_dir() {
  echo "$BASE_DIR/.test/tmp/$1"
}

create_abs_dir() {
  mkdir -p "$1"
  echo "$1"
}

create_dir() {
  create_abs_dir "$(get_dir "$1")"
}

create_tmp_dir() {
  create_dir "tmp/$1"
}

remove_dir() {
  rm -rf "$BASE_DIR/.test/$1"
}

remove_tmp_dirs() {
  remove_dir "tmp/"
}
