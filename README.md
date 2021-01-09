# Create bootable USB

```shell
# find usb drive name
sudo fdisk -l
# unmount usb drive
sudo umount /dev/sdb
# use Linux ISO image to create bootable usb drive
sudo dd bs=4M if=Fedora-Workstation-Live-x86_64-33-1.2.iso of=/dev/sdb conv=fsync
# sync just in case
sudo sync
```
