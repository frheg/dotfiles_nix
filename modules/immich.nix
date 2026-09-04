{ config, pkgs, lib, ... }:
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/var/lib/immich";
    database.createDB = true;
    redis.enable = true;
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 2283 ];
}
