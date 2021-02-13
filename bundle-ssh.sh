#!/bin/bash

set -e

(
  log_bundle "ssh"
  #
  # deps
  #
  lazy_install "ncat"
  sudo apt-get install -y augeas-tools openssh-server fail2ban
  #
  # lazy rsa keypair
  #
  DEFAULT_SSH_KEY=~/.ssh/id_rsa
  mkdir -p ~/.ssh/
  if [ -f "$DEFAULT_SSH_KEY" ]; then
    log_already_exists "$DEFAULT_SSH_KEY"
  else
    log_creating "$DEFAULT_SSH_KEY"
    ssh-keygen -t rsa -b 4096 -N '' -f $DEFAULT_SSH_KEY
  fi
  #
  # ssh server config
  #
  sudo systemctl enable ssh
  sudo augtool --autosave \
   'set /files/etc/ssh/sshd_config/PasswordAuthentication no'
  sudo augtool --autosave \
   'set /files/etc/ssh/sshd_config/ChallengeResponseAuthentication no'
  #
  # ssh client config
  #
  touch ~/.ssh/config
  augtool print /files$HOME/.ssh/config
  augtool --autosave \
    "set /files$HOME/.ssh/config/Host[.='github.com'] 'github.com'"
  augtool --autosave \
    "set /files$HOME/.ssh/config/Host[.='github.com']/HostName 'github.com'"
  augtool --autosave \
    "set /files$HOME/.ssh/config/Host[.='github.com']/IdentityFile '$DEFAULT_SSH_KEY'"
  augtool --autosave \
    "set /files$HOME/.ssh/config/Host[.='github.com']/IdentitiesOnly 'yes'"
  augtool --autosave \
    "set /files$HOME/.ssh/config/Host[.='*.onion'] '*.onion'"
  augtool --autosave \
    "set /files$HOME/.ssh/config/Host[.='*.onion']/proxyCommand 'ncat --proxy 127.0.0.1:9050 --proxy-type socks5 %h %p'"
  sudo systemctl restart ssh
)

