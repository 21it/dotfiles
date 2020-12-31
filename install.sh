#!/bin/bash

set -e

DOTFILES_SOURCE_DIR="$(dirname "$(readlink -f "$0")")"

log () {
  echo "$1 ==> $2"
}

log_error () {
  log "error" "$1"
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

if [[ $UID == 0 ]]; then
  log_error "please don't run this script with sudo!"
  exit 1
fi

log_updating "apt-get"
sudo apt-get update -y

lazy_copy () {
  local DOTFILES_SOURCE="$DOTFILES_SOURCE_DIR/$1"
  local DOTFILES_TARGET="$2"
  local DOTFILES_TARGET_DIR="$(dirname "$(readlink -f "$2")")"
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

(
  log_installing "i3wm"
  sudo apt-get install -y i3 unclutter-xfixes
  lazy_copy i3wm-config ~/.config/i3/config
)

(
  log_installing "vim"
  sudo apt-get install -y git vim nodejs
  log_installing "vim_runtime"
  DOTFILES_TARGET=~/.vim_runtime
  if [ -d "$DOTFILES_TARGET" ]; then
    log_already_exists "$DOTFILES_TARGET"
  else
    log_installing "$DOTFILES_TARGET"
    git clone \
      https://github.com/tim2CF/ultimate-haskell-ide.git \
      "$DOTFILES_TARGET"
    sh "$DOTFILES_TARGET/install_awesome_vimrc.sh"
  fi
)

if ! command -v nix &> /dev/null
then
  (
    log_installing "nix"
    cd ~/Downloads
    sudo apt-get install -y gnupg2
    curl -o install-nix-2.3.10 \
      https://releases.nixos.org/nix/nix-2.3.10/install
    curl -o install-nix-2.3.10.asc \
      https://releases.nixos.org/nix/nix-2.3.10/install.asc
    gpg2 \
      --keyserver hkps://keyserver.ubuntu.com \
      --recv-keys B541D55301270E0BCF15CA5D8170B4726D7198DE
    gpg2 --verify ./install-nix-2.3.10.asc
    sh ./install-nix-2.3.10
  )
else
  log_already_installed "nix"
fi

NIX_CHANNELS="$(nix-channel --list)"
EXPECTED_NIX_CHANNELS="nixpkgs https://nixos.org/channels/nixos-20.09"
if [ "$NIX_CHANNELS" != "$EXPECTED_NIX_CHANNELS" ]; then
  log_error "got '$NIX_CHANNELS' instead of '$EXPECTED_NIX_CHANNELS'"
  log_installing "nixpkgs"
  nix-channel --add https://nixos.org/channels/nixos-20.09 nixpkgs
  nix-channel --update
else
  log_already_installed "nixpkgs"
fi

strict_install () {
  log_installing "$1"
  if [ -z "$2" ]; then
    nix-env -iP "$1"
  else
    eval "$2"
  fi
}

lazy_install () {
  # 1st arg = executable name (required)
  # 2nd arg = pkg name (optional)
  # 3rd arg = installation command (optional)
  local PKG="$([ -z "$2" ] && echo "$1" || echo "$2")"
  command -v "$1" > /dev/null && \
    log_already_installed "$PKG" || \
    strict_install "$PKG" "$3"
}

for X in "castget" "irssi" "termite"; do
  lazy_install $X
done
