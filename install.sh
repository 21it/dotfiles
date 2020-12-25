#!/bin/bash

set -e

DOTFILES_DIR="$(dirname "$(readlink -f "$0")")"

if [[ $UID == 0 ]]; then
  echo "==> Please don't run this script with sudo!"
  exit 1
fi

echo "==> Updating apt-get ..."
sudo apt-get update -y

(
  echo "==> Installing i3wm ..."
  sudo apt-get install -y i3
  echo "==> Installing i3wm-config ..."
  mkdir -p ~/.config/i3/
  cp "$DOTFILES_DIR/i3wm-config" ~/.config/i3/config
)

(
  echo "==> Installing vim ..."
  sudo apt-get install -y git vim nodejs
  echo "==> Installing vim-ide ..."
  git clone \
    https://github.com/tim2CF/ultimate-haskell-ide.git \
    ~/.vim_runtime
  sh ~/.vim_runtime/install_awesome_vimrc.sh
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
