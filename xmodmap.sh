#!/bin/sh
set -e
setxkbmap -layout us,ru -variant altgr-intl, -option grp:alt_space_toggle
xmodmap ~/.Xmodmap

