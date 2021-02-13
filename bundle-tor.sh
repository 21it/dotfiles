#!/bin/bash

set -e

#
#  We need to add a couple of configuration options to the
#  default Tor configuration file.
#
#  $ sudo vi /etc/tor/torrc
#
#  At the bottom of that file, add the following:
#
#    HiddenServiceDir /var/lib/tor/ssh/
#    HiddenServicePort 22 127.0.0.1:22
#
#  Save and close the file. Restart Tor with the command:
#
#  $ sudo systemctl restart tor
#
#  The restarting of Tor will generate all the necessary
#  files within /var/lib/tor/ssh. In that directory will be
#  the hostname you'll need to use to connect to the server
#  from the remote client. To find out that hostname, issue
#  the command:
#
#  $ sudo cat /var/lib/tor/ssh/hostname
#
#  Head over to your client, where you've also installed Tor.
#  In order to connect to the server, you'll use the hostname
#  provided by the cat command from above.
#  So to make the connection, you'd issue the command:
#
#  $ ssh USER@HOSTNAME
#
#  Where USER is a remote user and HOSTNAME
#  is the hostname provided by Tor.
#
(
  log_bundle "tor"
  TOR_SSH_HOST=/var/lib/tor/ssh/hostname
  sudo apt-get install tor -y
  sudo systemctl enable tor
  if sudo bash -c "[ -f "$TOR_SSH_HOST" ]"; then
    log_success "tor ssh hostname is $(sudo cat "$TOR_SSH_HOST")"
  else
    log_error "FILE $TOR_SSH_HOST DOES NOT EXIST"
    log_error "PLEASE FIX /etc/tor/torrc"
  fi
)
