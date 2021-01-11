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

Then reboot your computer. If something fails - you can play around with installation script as many times as you want - it's lazy and will never do the same job twice.
