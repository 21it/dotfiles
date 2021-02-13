#!/bin/bash

set -e

DOTFILES_SOURCE_DIR="$(dirname "$(readlink -m "$0")")"
source "$DOTFILES_SOURCE_DIR/lib-shared.sh"
source "$DOTFILES_SOURCE_DIR/lib-nix.sh"

if [[ $UID == 0 ]]; then
  log_error "please don't run this script with sudo!"
  exit 1
fi

log_updating "apt-get"
sudo apt-get update -y

(
  log_bundle "nix"
  if ! command -v nix &> /dev/null
  then
    log_installing "nix"
    mkdir -p ~/Downloads
    cd ~/Downloads
    sudo apt-get install -y gnupg2 curl tar
    curl -o install-nix-2.3.10 \
      https://releases.nixos.org/nix/nix-2.3.10/install
    curl -o install-nix-2.3.10.asc \
      https://releases.nixos.org/nix/nix-2.3.10/install.asc
    gpg2 \
      --keyserver hkps://keyserver.ubuntu.com \
      --recv-keys B541D55301270E0BCF15CA5D8170B4726D7198DE
    gpg2 --verify ./install-nix-2.3.10.asc
    sh ./install-nix-2.3.10
  else
    log_already_installed "nix"
  fi
)

(
  log_bundle "nixpkgs"
  NIX_CHANNELS="$(nix-channel --list)"
  EXPECTED_NIX_CHANNELS="nixpkgs https://nixos.org/channels/nixos-20.09"
  if [ "$NIX_CHANNELS" != "$EXPECTED_NIX_CHANNELS" ]; then
    log_error "got '$NIX_CHANNELS' instead of '$EXPECTED_NIX_CHANNELS'"
    log_installing "nixpkgs"
    nix-channel --add https://nixos.org/channels/nixos-20.09 nixpkgs
    nix-channel --update
  else
    log_already_installed "nixpkgs"
  fi
)

(
  log_bundle "vim"
  lazy_install "vim"
  lazy_install "git"
  lazy_install "ag" "silver-searcher"
  lazy_install "node" "nodejs"
  lazy_install "grip" "python38Packages.grip"
  lazy_install "xdg-open" "xdg_utils"
  DOTFILES_TARGET=~/.vim_runtime
  if [ -d "$DOTFILES_TARGET" ]; then
    log_already_exists "$DOTFILES_TARGET"
  else
    log_installing "$DOTFILES_TARGET"
    git clone \
      git@github.com:tim2CF/ultimate-haskell-ide.git \
      "$DOTFILES_TARGET"
    sh "$DOTFILES_TARGET/install_awesome_vimrc.sh"
  fi
)

(
  log_bundle "i3wm"
  sudo apt-get install -y i3
  lazy_install "light"
  lazy_install "playerctl"
  lazy_install "xbacklight" "xorg.xbacklight"
  lazy_install "unclutter" "unclutter-xfixes"
  lazy_copy i3wm-config ~/.config/i3/config
  lazy_copy i3wm-status-config ~/.i3status.conf
)

(
  log_bundle "termite"
  lazy_copy termite-config ~/.config/termite/config
  lazy_install "termite" "termite" "nix-env -iAP nixpkgs.termite && tic -x $DOTFILES_SOURCE_DIR/termite.terminfo"
)

#
# utility for Android file transfer:
#
#   fusermount -u ~/transfer
#   jmtpfs ~/transfer
#   rsync -azP --ignore-existing \
#     ~/podcast/ \
#     ~/transfer/SD\ Card\ Storage/downloads/podcast
#
(
  log_bundle "jmtpfs"
  mkdir -p ~/transfer
  lazy_install "jmtpfs"
)

#
# utility for RSS podcast downloads:
#
#   castget -v -p
#
(
  log_bundle "castget"
  lazy_install "sed"
  lazy_copy castget-config ~/.castgetrc
  sed -i "s|\$HOME|$HOME|g" ~/.castgetrc
  mkdir -p ~/podcast/4keelekodi
  mkdir -p ~/podcast/lightning-junkies
  mkdir -p ~/podcast/stephan-livera
  mkdir -p ~/podcast/haskell-weekly
  mkdir -p ~/podcast/the-haskell-cast
  lazy_install "castget"
)

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

#
# tor
#
#   We need to add a couple of configuration options to the
#   default Tor configuration file.
#
#   $ sudo vi /etc/tor/torrc
#
#   At the bottom of that file, add the following:
#
#     HiddenServiceDir /var/lib/tor/ssh/
#     HiddenServicePort 22 127.0.0.1:22
#
#   Save and close the file. Restart Tor with the command:
#
#   $ sudo systemctl restart tor
#
#   The restarting of Tor will generate all the necessary
#   files within /var/lib/tor/ssh. In that directory will be
#   the hostname you'll need to use to connect to the server
#   from the remote client. To find out that hostname, issue
#   the command:
#
#   $ sudo cat /var/lib/tor/ssh/hostname
#
#   Head over to your client, where you've also installed Tor.
#   In order to connect to the server, you'll use the hostname
#   provided by the cat command from above.
#   So to make the connection, you'd issue the command:
#
#   $ ssh USER@HOSTNAME
#
#   Where USER is a remote user and HOSTNAME
#   is the hostname provided by Tor.
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

for X in "irssi" "stack" "elixir" "docker-compose" "htop" "gcal"; do
  lazy_install $X
done

sudo apt-get autoremove -y

log_success "installation finished"
