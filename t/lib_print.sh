COLOR_GREEN="\033[1m\033[32m"
COLOR_RED="\033[1m\033[31m"
COLOR_CYAN="\033[1m\033[36m"
COLOR_OFF="\033[0m"

print_success() {
  echo -e "${COLOR_GREEN}success${COLOR_OFF}"
}

print_fail() {
  echo -e "${COLOR_RED}fail${COLOR_OFF}"
}

print_title() {
  echo -e "${COLOR_CYAN}running test $1...${COLOR_OFF}"
}

print_debug() {
  if [ "$DEBUG" = "true" ]; then
    echo "$@"
  fi
}
