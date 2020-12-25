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

(
  echo "==> Installing termite-deps ..."
  sudo apt-get install -y build-essential \
    git \
    g++ \
    libgtk-3-dev \
    gtk-doc-tools \
    gnutls-bin \
    valac \
    intltool \
    libpcre2-dev \
    libglib3.0-cil-dev \
    libgnutls28-dev \
    libgirepository1.0-dev \
    libxml2-utils \
    gperf \
    neofetch
)
