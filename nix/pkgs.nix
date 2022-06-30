{
  pkgs ? import <nixpkgs> {}
}:
with pkgs;
{
  inherit irssi slack skypeforlinux signal-desktop;
  inherit yarn;
  inherit xkbset xdotool;
  inherit ormolu hpack;
  inherit patchelf;
  inherit expect;
  inherit feh imlib2 imagemagick;
  inherit htmldoc pandoc;
  inherit qmk;
  inherit tutanota-desktop element-desktop;
  inherit ccrypt;
}
