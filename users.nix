{
  ...
}:

{
  users.users.nyan = {
    description = "Nyan";
    # You can change this password using 'passwd' or set it here.
    initialPassword = "ABCdef123";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      # Put your SSH public keys here.
    ];
  };
}
