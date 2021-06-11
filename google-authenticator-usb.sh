#!/bin/bash

set -e

#
# As root, create a new file named 80-usb.rules
# in /etc/udev/rules.d/ directory and paste these lines –
#
# ACTION=="add", SUBSYSTEMS=="usb", KERNEL=="sd[a-z][0-9]", ATTRS{idVendor}=="<vendor-id>", ATTRS{idProduct}=="<device-id>", RUN+="/bin/sh <dotfiles-dir>/google-authenticator-usb.sh %k"
#
# ACTION=="remove", SUBSYSTEMS=="usb", KERNEL=="sd[a-z][0-9]", ATTRS{idVendor}=="<vendor-id>", ATTRS{idProduct}=="<device-id>", RUN+="/bin/sh <dotfiles-dir>/something-else.sh %k"
#
# You can use usb-devices cli tool to find out details about your USB device
#

export DISPLAY=:0
export XAUTHORITY=/var/lib/lightdm/.Xauthority
export DEV="$1"
export VOLUME="/media/$DEV"
export KEY_DIR="$VOLUME/.2fa"

sudo mkdir -p "$VOLUME"
sudo mount "/dev/$DEV" "$VOLUME" || echo "Volume $VOLUME is already mounted"
sudo mkdir -p "$KEY_DIR"

KEY_FILE=`zenity \
  --list \
  --title="Select 2fa secret key" \
  --column="Key" \
  $(ls "$KEY_DIR")`

KEY="$(cat "$KEY_DIR/$KEY_FILE")"

PASSWORD=`zenity \
  --title="Enter 2fa encryption password" \
  --password`

CODE=`oathtool \
  -b --totp \
  "$(echo "$KEY" | openssl enc -aes-256-cbc -a -d -pbkdf2 -k "$PASSWORD")"`

notify-send -t 10000 "$CODE"

sudo sync

sudo umount "$VOLUME"
