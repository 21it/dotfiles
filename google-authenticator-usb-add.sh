#!/bin/bash

set -e

#
# Run this script to add new 2fa key
# It should be encoded as plain text
# For example DK2DEFASV26A====
#

read -p "block-device> " DEV
export VOLUME="/media/$DEV"
export KEY_DIR="$VOLUME/.2fa"

sudo mkdir -p "$VOLUME"
sudo mount "/dev/$DEV" "$VOLUME" || echo "Volume $VOLUME is already mounted"
sudo mkdir -p "$KEY_DIR"

read -p "key-name> " KEY_NAME
read -s -p "key-secret> " KEY_SECRET

echo "$KEY_SECRET" | \
  sudo openssl enc -aes-256-cbc -a -pbkdf2 -out "$KEY_DIR/$KEY_NAME"

sudo sync

sudo umount "$VOLUME"

echo "success!"
