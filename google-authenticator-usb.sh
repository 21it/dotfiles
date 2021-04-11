#!/bin/bash

set -e

# Now, as root, create a new file named 80-usb.rules
# in /etc/udev/rules.d/ directory and paste these lines –
#
# ACTION=="add", SUBSYSTEMS=="usb", ATTR{idVendor}=="<vendor-id>", ATTR{idProduct}=="<device-id>", RUN+="/usr/local/bin/usb-lock.sh unlock"
# ACTION=="remove", SUBSYSTEMS=="usb", ENV{ID_VENDOR_ID}=="<vendor-id>", ENV{ID_MODEL_ID}=="<device-id>", RUN+="/usr/local/bin/usb-lock.sh lock"

notify-send "$1"

