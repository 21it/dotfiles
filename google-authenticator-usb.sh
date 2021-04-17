#!/bin/bash

set -e

#
# As root, create a new file named 80-usb.rules
# in /etc/udev/rules.d/ directory and paste these lines –
#
# ACTION=="add", SUBSYSTEMS=="usb", ATTR{idVendor}=="<vendor-id>", ATTR{idProduct}=="<device-id>", RUN+="<dotfiles-dir>/google-authenticator-usb.sh"
# ACTION=="remove", SUBSYSTEMS=="usb", ENV{ID_VENDOR_ID}=="<vendor-id>", ENV{ID_MODEL_ID}=="<device-id>", RUN+="<other-dir>/something-else.sh"

export DISPLAY=:0
export XAUTHORITY=/var/lib/lightdm/.Xauthority
export DEV="$1"
export VOLUME="/media/$DEV"
export KEYDIR="$VOLUME/.2fa"

mkdir -p "$VOLUME"
mount "/dev/$DEV" "$VOLUME"
mkdir -p "$KEYDIR"

FILE=`zenity \
  --list \
  --title="Select 2fa" \
  --column="Secret" \
  $(ls "$KEYDIR")`

CODE=`oathtool \
  -b --totp \
  "$(gpg2 --decrypt "$KEYDIR/$FILE" 2>/dev/null)"`

notify-send -t 10000 "$CODE"

umount "$VOLUME"
