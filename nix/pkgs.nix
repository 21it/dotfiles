{
  pkgs ? import <nixpkgs> {}
}:
with pkgs;
{
  pidgin-with-plugins = pidgin-with-plugins.override {
    plugins = [
      purple-slack
      telegram-purple
      skype4pidgin
    ];
  };
  irssi = irssi;
  telegram-desktop = tdesktop;
  slack = slack;
}
