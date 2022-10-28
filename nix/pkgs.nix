{
  pkgs ? import <nixpkgs> {}
}:
with pkgs;
{
  inherit irssi slack;
  inherit yarn;
  inherit xkbset xdotool;
  inherit ormolu hpack;
  inherit patchelf;
  inherit expect;
  inherit feh imlib2 imagemagick;
  inherit htmldoc pandoc;
  inherit qmk;
  inherit ccrypt;
  inherit libreoffice xournal;
  vi = import ./vi.nix;
}
