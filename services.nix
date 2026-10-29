{
  ...
}:

{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  services.openssh.enable = true;
  programs.mosh.enable = true;
  environment.enableAllTerminfo = true;
}
