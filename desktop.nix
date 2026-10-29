{
  pkgs,
  ...
}:

{
  # You can use any display manager and desktop environment you want.
  # However, I recommend using GDM as it has a virtual keyboard and touch support.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    gnome-console
  ];
  environment.systemPackages = with pkgs; [
    ptyxis
  ];

  services.flatpak.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  services.printing.enable = true;
  hardware.graphics.extraPackages = [ pkgs.intel-vaapi-driver ];

  hardware.sensor.iio.enable = true;

  # Fixes auto-rotation not working on Mutter 50.5 and earlier
  # This can be removed once nixpkgs updates to 50.6 or 51
  nixpkgs.overlays = [
    (final: prev: {
      mutter = prev.mutter.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (prev.fetchpatch {
            url = "https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/4962.diff";
            hash = "sha256-MxVKeuWgq2id4RSQopJRiHA/AWAOTU+pdomAh+TkbN4=";
          })
        ];
      });
    })
  ];

  /*
  boot.plymouth = {
    enable = true;
    font = "${pkgs.inter}/share/fonts/truetype/InterVariable.ttf";
  };
  boot.kernelParams = [ "quiet" ];
  */
}
