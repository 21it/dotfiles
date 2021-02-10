#!/bin/bash

set -e

DOTFILES_SOURCE_DIR="$(dirname "$(readlink -m "$0")")"

log () {
  echo "$1 ==> $2"
}
log_error () {
  log "error" "$1"
}

log_success () {
  log "success" "$1"
}

log_bundle () {
  log "bundle" "$1"
}

log_updating () {
  log "updating" "$1"
}

log_already_exists () {
  log "already exists" "$1"
}

log_creating () {
  log "creating" "$1"
}

log_installing () {
  log "installing" "$1"
}

log_already_installed () {
  log "already installed" "$1"
}

lazy_copy () {
  local DOTFILES_SOURCE="$DOTFILES_SOURCE_DIR/$1"
  local DOTFILES_TARGET="$2"
  local DOTFILES_TARGET_DIR="$(dirname "$(readlink -m "$2")")"
  if [ -d "$DOTFILES_TARGET_DIR" ]; then
    log_already_exists "$DOTFILES_TARGET_DIR"
  else
    log_creating "$DOTFILES_TARGET_DIR"
    mkdir -p "$DOTFILES_TARGET_DIR"
  fi
  if [ -f "$DOTFILES_TARGET" ]; then
    log_already_exists "$DOTFILES_TARGET"
  else
    log_creating "$DOTFILES_TARGET"
    cp "$DOTFILES_SOURCE" "$DOTFILES_TARGET"
  fi
}

lazy_install () {
  # 1st arg = executable name (required)
  # 2nd arg = pkg name (optional)
  # 3rd arg = installation command (optional)
  local PKG="$([ -z "$2" ] && echo "$1" || echo "$2")"
  command -v "$1" > /dev/null && \
    log_already_installed "$PKG" || \
    strict_install "$PKG" "$3"
}

strict_install () {
  log_installing "$1"
  if [ -z "$2" ]; then
    nix-env -iAP "nixpkgs.$1"
  else
    eval "$2"
  fi
}

if [[ $UID == 0 ]]; then
  log_error "please don't run this script with sudo!"
  exit 1
fi

log_updating "apt-get"
sudo apt-get update -y

log_bundle "nix"
if ! command -v nix &> /dev/null
then
  (
    log_installing "nix"
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
  )
else
  log_already_installed "nix"
fi

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

#
# ssh
#
#   Disable password login! Edit ssh configuration by setting
#   “ChallengeResponseAuthentication” and “PasswordAuthentication”
#   to “no” (uncomment the line by removing # if necessary).
#   Save and exit.
#
#   $ sudo vi /etc/ssh/sshd_config
#
#   Restart the SSH daemon, then exit and log in again.
#
#   $ sudo systemctl restart sshd
#
(
  TERM=xterm-color
  log_bundle "ssh"
  sudo apt-get install -y openssh-server ufw fail2ban
  sudo systemctl enable ssh
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow 22 comment 'allow SSH'
  sudo ufw enable
  sudo systemctl enable ufw
  sudo ufw status
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
#     HiddenServicePort 22
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
#   $ sudo torify ssh USER@HOSTNAME
#
#   Where USER is a remote user and HOSTNAME
#   is the hostname provided by Tor.
#
(
  TERM=xterm-color
  TOR_SSH_HOST=/var/lib/tor/ssh/hostname
  log_bundle "tor"
  sudo apt-get install tor -y
  sudo systemctl enable tor
  if sudo bash -c "[ -f "$TOR_SSH_HOST" ]"; then
    log_success "tor ssh hostname is $(sudo cat "$TOR_SSH_HOST")"
  else
    log_error "FILE $TOR_SSH_HOST DOES NOT EXIST"
    log_error "PLEASE CONFIGURE /etc/tor/torrc ACCORDING install.sh"
  fi
)

for X in "irssi" "stack" "elixir" "docker-compose" "htop" "gcal"; do
  lazy_install $X
done

sudo apt-get autoremove -y

log_success "installation finished"
