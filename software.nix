{
  pkgs,
  ...
}:

{
  environment.variables = {
    EDITOR = "micro";
  };

  programs.fish.enable = true;
  programs.htop.enable = true;
  programs.git.enable = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    micro
    helix
    file
    ripgrep
    fd
    xxd
    rsync
    jq
    fastfetch
    ncdu
    nixd
  ];
}
