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

  nixpkgs.overlays = [
    (_: prev: {
      mbrola-voices = prev.mbrola-voices.override {
        # only ship with one voice per language
        languages = [ "*1" ];
      };
    })
  ];
}
