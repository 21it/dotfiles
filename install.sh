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
  EXPECTED_NIX_CHANNELS=$'nixpkgs https://nixos.org/channels/nixos-22.05\nnixpkgs-unstable https://nixos.org/channels/nixos-unstable'
  if [ "$NIX_CHANNELS" != "$EXPECTED_NIX_CHANNELS" ]; then
    log_error "got '$NIX_CHANNELS' instead of '$EXPECTED_NIX_CHANNELS'"
    log_installing "nixpkgs"
    nix-channel --add https://nixos.org/channels/nixos-22.05 nixpkgs
    nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs-unstable
  else
    log_already_installed "nixpkgs"
  fi
  nix-channel --update
)

(
  log_bundle "i3wm"
  sudo apt-get install -y i3
  lazy_install "light"
  lazy_install "playerctl"
  lazy_install "brightnessctl"
  lazy_install "unclutter" "unclutter-xfixes"
  lazy_copy i3wm-config ~/.config/i3/config
  lazy_copy i3wm-status-config ~/.i3status.conf
)

(
  log_bundle "termite"
  lazy_copy termite-config ~/.config/termite/config
  lazy_install "termite" "termite" "nix-env -iA nixpkgs.termite && tic -x $DOTFILES_SOURCE_DIR/termite.terminfo"
  sudo apt-get install -y language-pack-ru ttf-ancient-fonts
  lazy_copy .Xmodmap ~/.Xmodmap
)

#
# utility for Android file transfer:
#
#   fusermount -u ~/transfer
#   jmtpfs ~/transfer
#   sudo rsync -azP --ignore-existing \
#     ~/podcast/* \
#     ~/transfer/SD\ Card\ Storage/downloads/podcast
#
# or for SD-card
#
# sudo rsync -azP --ignore-existing ~/podcast/* ~/transfer/
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
  mkdir -p ~/podcast/compositional
  mkdir -p ~/podcast/tales-from-the-crypt
  mkdir -p ~/podcast/spanish-podcast
  lazy_install "castget"
)

for X in "ufw" "ssh" "tor" "kaios"; do
  source "$DOTFILES_SOURCE_DIR/bundle-$X.sh"
done

(
  log_bundle "clipboard"
  lazy_install "xclip"
  lazy_install "maim"
  touch ~/.bash_aliases
  lazy_append "alias pbcopy='xclip -selection clipboard'" ~/.bash_aliases
  lazy_append "alias pbpaste='xclip -selection clipboard -o'" ~/.bash_aliases
)

for X in "erlang" "elixir" "docker-compose" "htop" "gcal"; do
  lazy_install $X
done

(
  log_bundle "stack"
  lazy_install "stack" "stack" "nix-env -iA nixpkgs-unstable.stack"
  lazy_copy stack-config ~/.stack/config.yaml
  sudo apt-get install build-essential g++ gcc libc6-dev libffi-dev libgmp-dev make xz-utils zlib1g-dev gnupg netbase -y
)

(
  log_bundle "smartcard"
  sudo apt-get install libccid opensc -y
  lazy_install "gp" "global-platform-pro"
  NIXPKGS_ALLOW_INSECURE=1 lazy_install "gpshell"
)

(
  log_bundle "pkgs"
  NIXPKGS_ALLOW_UNFREE=1 nix-env -i -f ./nix/pkgs.nix
)

sudo apt-get install tlp -y
sudo apt-get install ffmpeg redshift net-tools -y
sudo apt-get install alsa-base pulseaudio -y
sudo snap install ledger-live-desktop
# for docker buildx
sudo apt-get install -y qemu-user-static binfmt-support

(
  log_bundle "usb-2fa"
  sudo apt-get install -y oathtool gnupg2 lightdm
  lazy_install "zenity" "gnome3.zenity"
  lazy_install "openssl"
)

(
  log_bundle "yewtube"
  sudo apt-get install python3-pip mpv -y
  pip install yewtube
  lazy_copy yewtube-config ~/.config/mps-youtube/config.json
)

sudo apt-get autoremove -y

log_success "installation finished"
