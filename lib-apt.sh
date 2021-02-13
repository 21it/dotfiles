#!/bin/bash

set -e

DOTFILES_SOURCE_DIR="$(dirname "$(readlink -m "$0")")"
source "$DOTFILES_SOURCE_DIR/lib-shared.sh"

lazy_install () {
  # 1st arg = executable name (required)
  # 2nd arg = pkg name (optional)
  # 3rd arg = installation command (optional)
  local PKG="$([ -z "$2" ] && echo "$1" || echo "$2")"
  command -v "$1" > /dev/null && \
    log_already_installed "$PKG" || \
    strict_install "$PKG" "$3"
}

strict_install () {
  log_installing "$1"
  if [ -z "$2" ]; then
    sudo apt-get install -y "$1"
  else
    eval "$2"
  fi
}
