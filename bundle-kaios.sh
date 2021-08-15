#!/bin/bash

set -e

#
# Enable debug mode with *#*#33284#*#*
# And then
#
#   adb devices
#

DOTFILES_SOURCE_DIR="$(dirname "$(readlink -m "$0")")"
source "$DOTFILES_SOURCE_DIR/lib-shared.sh"
source "$DOTFILES_SOURCE_DIR/lib-nix.sh"

if [[ $UID == 0 ]]; then
  log_error "Please don't run this script with sudo!"
  exit 1
fi

(
  log_bundle "kaios"
  sudo apt-get install android-tools-adb android-tools-fastboot -y
  cat "$DOTFILES_SOURCE_DIR/51-android.rules" \
    | sudo tee >/dev/null /etc/udev/rules.d/51-android.rules
  sudo chmod a+r /etc/udev/rules.d/51-android.rules
  sudo udevadm control --reload-rules
  lazy_copy adb_usb.ini ~/.android/adb_usb.ini
)
