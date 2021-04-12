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
  EXPECTED_NIX_CHANNELS=$'nixpkgs https://nixos.org/channels/nixos-20.09\nnixpkgs-unstable https://nixos.org/channels/nixos-unstable'
  if [ "$NIX_CHANNELS" != "$EXPECTED_NIX_CHANNELS" ]; then
    log_error "got '$NIX_CHANNELS' instead of '$EXPECTED_NIX_CHANNELS'"
    log_installing "nixpkgs"
    nix-channel --add https://nixos.org/channels/nixos-20.09 nixpkgs
    nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs-unstable
  else
    log_already_installed "nixpkgs"
  fi
  nix-channel --update
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
  lazy_install "brightnessctl"
  lazy_install "unclutter" "unclutter-xfixes"
  lazy_copy i3wm-config ~/.config/i3/config
  lazy_copy i3wm-status-config ~/.i3status.conf
)

(
  log_bundle "termite"
  lazy_copy termite-config ~/.config/termite/config
  lazy_install "termite" "termite" "nix-env -iAP nixpkgs.termite && tic -x $DOTFILES_SOURCE_DIR/termite.terminfo"
  sudo apt-get install -y language-pack-ru
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

for X in "ufw" "ssh" "tor"; do
  source "$DOTFILES_SOURCE_DIR/bundle-$X.sh"
done

#
# TODO : automate this aliasing
#
#  alias pbcopy='xclip -selection clipboard'
#  alias pbpaste='xclip -selection clipboard -o'
#
(
  log_bundle "pbcopy"
  lazy_install "xclip"
)

for X in "irssi" "elixir" "docker-compose" "htop" "gcal"; do
  lazy_install $X
done

(
  log_bundle "stack"
  lazy_install "stack" "stack" "nix-env -iAP nixpkgs-unstable.stack"
  lazy_copy stack-config ~/.stack/config.yaml
)

(
  log_bundle "smartcard"
  sudo apt-get install libccid opensc -y
  lazy_install "gp" "global-platform-pro"
)

lazy_install "slack" "slack" "NIXPKGS_ALLOW_UNFREE=1 nix-env -iAP nixpkgs.slack"

sudo apt-get install ffmpeg redshift -y

(
  log_bundle "2fa"
  sudo apt-get install -y oathtool gnupg2 lightdm
  lazy_install "zenity" "gnome3.zenity"
)

sudo apt-get autoremove -y

log_success "installation finished"
