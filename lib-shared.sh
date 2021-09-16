#!/bin/bash

set -e

TERM=xterm-color
DOTFILES_SOURCE_DIR="$(dirname "$(readlink -m "$0")")"

log () {
  echo "$1 ==> $2"
}
log_error () {
  log "error" "$1"
}

log_success () {
  log "success" "$1"
}

log_bundle () {
  log "bundle" "$1"
}

log_updating () {
  log "updating" "$1"
}

log_already_exists () {
  log "already exists" "$1"
}

log_creating () {
  log "creating" "$1"
}

log_installing () {
  log "installing" "$1"
}

log_already_installed () {
  log "already installed" "$1"
}

lazy_copy () {
  local DOTFILES_SOURCE="$DOTFILES_SOURCE_DIR/$1"
  local DOTFILES_TARGET="$2"
  local DOTFILES_TARGET_DIR="$(dirname "$(readlink -m "$2")")"
  if [ -d "$DOTFILES_TARGET_DIR" ]; then
    log_already_exists "$DOTFILES_TARGET_DIR"
  else
    log_creating "$DOTFILES_TARGET_DIR"
    mkdir -p "$DOTFILES_TARGET_DIR"
  fi
  if [ -f "$DOTFILES_TARGET" ]; then
    log_already_exists "$DOTFILES_TARGET"
  else
    log_creating "$DOTFILES_TARGET"
    cp "$DOTFILES_SOURCE" "$DOTFILES_TARGET"
  fi
}

lazy_append () {
  grep -q "$1" "$2" || echo "$1" >> "$2"
}
