# Create bootable USB

```shell
# find usb drive name
sudo fdisk -l
# unmount usb drive
sudo umount /dev/sdb
# use Linux ISO image to create bootable usb drive
sudo dd bs=4M if=image.iso of=/dev/sdb conv=fsync
# sync just in case
sudo sync
```

# Install OS and dotfiles

Reboot your computer holding `option` key. Choose USB drive as bootable volume and install OS. After login generate new RSA key:

```shell
ssh-keygen -t rsa -b 4096
cat ~/.ssh/id_rsa.pub
```

Then add new RSA key to your github account and clone this repo and install dotfiles:

```shell
sudo apt-get update -y
sudo apt-get install -y git
mkdir -p ~/MYprojects
git clone git@github.com:tim2CF/dotfiles.git ~/MYprojects/dotfiles
~/MYprojects/dotfiles/install.sh
```

In the middle of the installation process you might see message similar to this:

```shell
Installation finished!  To ensure that the necessary environment
variables are set, either log in again, or type

  . /home/timcf/.nix-profile/etc/profile.d/nix.sh

in your shell.
```

Just do whatever it says and rerun installation process:

```shell
~/MYprojects/dotfiles/install.sh
```

After successfull installation configure environment variables:

```shell
vi ~/.profile

export TERMINAL="termite"
export HEX_ORGANIZATION="x"
export HEX_API_KEY="secret"
export ROBOT_SSH_KEY="$(cat ~/.ssh/id_rsa | base64 --wrap=0)"
export VIM_BACKGROUND="light" # or "dark"
export VIM_COLOR_SCHEME="PaperColor" # or "jellybeans"
export GIT_AUTHOR_NAME="x"
export GIT_AUTHOR_EMAIL="x@x.com"
```

Then reboot your computer and choose `i3` as window manager on login. If something fails - you can play around with installation script as many times as you want - it's lazy and will never do the same job twice.

# HiDPI/Retina/5K display

If you are using HiDPI display then you need to configure X server:

```shell
vi ~/.Xresources

Xft.dpi: 192
URxvt.font: xft:FiraMono-Regular:size=10
Xft.autohint: 0
Xft.lcdfilter:  lcddefault
Xft.hintstyle:  hintfull
Xft.hinting: 1
Xft.antialias: 1
Xft.rgba: rgb
```

And then:

```shell
vi ~/.profile

export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export QT_AUTO_SCREEN_SCALE_FACTOR=1
```

# Docker

Docker installation is quite complex process which implies creation of new user group and systemd services. We don't want to automate it for now. Just follow the steps from official docker manual.
