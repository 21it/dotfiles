#!/bin/bash

set -e

DOTFILES_SOURCE_DIR="$(dirname "$(readlink -m "$0")")"
source "$DOTFILES_SOURCE_DIR/lib-shared.sh"
source "$DOTFILES_SOURCE_DIR/lib-apt.sh"

if [[ $UID == 0 ]]; then
  log_error "please don't run this script with sudo!"
  exit 1
fi

log_updating "apt-get"
sudo apt-get update -y

for X in "ufw" "ssh" "tor"; do
  source "$DOTFILES_SOURCE_DIR/bundle-$X.sh"
done

sudo apt-get autoremove -y

log_success "installation finished"
