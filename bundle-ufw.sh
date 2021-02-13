#!/bin/bash

set -e

(
  log_bundle "ufw"
  sudo apt-get install -y ufw
  #sudo ufw --force reset
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  #sudo ufw allow 22 comment 'allow ssh'
  sudo ufw enable
  sudo systemctl enable ufw
  sudo ufw status
)


