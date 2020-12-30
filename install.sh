#!/bin/bash

set -e

DOTFILES_SOURCE="$(dirname "$(readlink -f "$0")")"

if [[ $UID == 0 ]]; then
  echo "==> Please don't run this script with sudo!"
  exit 1
fi

echo "==> Updating apt-get ..."
sudo apt-get update -y

(
  echo "==> Installing i3wm ..."
  sudo apt-get install -y i3 unclutter-xfixes
  echo "==> Installing i3wm-config ..."
  mkdir -p ~/.config/i3
  DOTFILES_TARGET=~/.config/i3/config
  if [ -f "$DOTFILES_TARGET" ]; then
    echo "==> File $DOTFILES_TARGET already exists, skipping!"
  else
    echo "==> Installing i3wm-config into $DOTFILES_TARGET ..."
    cp "$DOTFILES_SOURCE/i3wm-config" "$DOTFILES_TARGET"
  fi
)

(
  echo "==> Installing vim ..."
  sudo apt-get install -y git vim nodejs
  echo "==> Installing vim-config ..."
  DOTFILES_TARGET=~/.vim_runtime
  if [ -d "$DOTFILES_TARGET" ]; then
    echo "==> Directory $DOTFILES_TARGET already exists, skipping!"
  else
    echo "==> Installing vim-config into $DOTFILES_TARGET ..."
    git clone \
      https://github.com/tim2CF/ultimate-haskell-ide.git \
      "$DOTFILES_TARGET"
    sh "$DOTFILES_TARGET/install_awesome_vimrc.sh"
  fi
)

if ! command -v nix &> /dev/null
then
  (
    echo "==> Installing nix ..."
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
  echo "==> Nix is already installed, skipping!"
fi

NIX_CHANNELS="$(nix-channel --list)"
EXPECTED_NIX_CHANNELS="nixpkgs https://nixos.org/channels/nixos-20.09"
if [ "$NIX_CHANNELS" != "$EXPECTED_NIX_CHANNELS" ]; then
  echo "==> Got '$NIX_CHANNELS' but expected '$EXPECTED_NIX_CHANNELS'"
  echo "==> Installing nixpkgs ..."
  nix-channel --add https://nixos.org/channels/nixos-20.09 nixpkgs
  nix-channel --update
else
  echo "==> Nix channels are already installed, skipping!"
fi

strict_install () {
  echo "==> Installing $1 ..."
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
    echo "==> $PKG is already installed, skipping!" || \
    strict_install "$PKG" "$3"
}

for X in "castget" "irssi" "termite"; do
  lazy_install $X
done
