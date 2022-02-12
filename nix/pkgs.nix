{
  pkgs ? import <nixpkgs> {}
}:
with pkgs;
{
  inherit irssi slack skypeforlinux;
  inherit yarn;
  inherit xkbset xdotool;
  inherit ormolu hpack;
  inherit patchelf;
  inherit expect;
  inherit feh imlib2 imagemagick;
  #tok = import (fetchTarball "https://github.com/21it/tok/tarball/848b16af983ba9687501a3864eef869ef70e9615");
}
