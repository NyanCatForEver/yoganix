{
  pkgs,
  ...
}:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "yoganix";
  time.timeZone = "Europe/Paris";
  services.xserver.xkb.layout = "fr";
  console.useXkbConfig = true;
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [ "fr_FR.UTF-8/UTF-8" ];
  };

  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
}
