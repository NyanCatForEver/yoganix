{
  ...
}:

{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.openssh.enable = true;
  programs.mosh.enable = true;
  environment.enableAllTerminfo = true;
}
