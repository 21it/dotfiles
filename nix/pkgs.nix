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
  inherit irssi tdesktop slack skypeforlinux;
  inherit yarn;
  inherit wine;
}
