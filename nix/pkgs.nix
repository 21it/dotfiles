{
  pkgs ? import <nixpkgs> {}
}:
with pkgs;
{
  inherit irssi slack skypeforlinux;
  inherit yarn;
  inherit xkbset xdotool;
}
