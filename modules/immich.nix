{ config, pkgs, lib, ... }:
{
  # Immich photo/video server, reachable only over the tailnet.
  #
  # Note on ports: kratos already runs a postgres:17-alpine Docker container
  # on 5432 for the homelab stack, so this NixOS postgres uses 5433 instead.
  # Immich has to be told about that separately -- it does not inherit the
  # port from services.postgresql.

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/var/lib/immich";
    redis.enable = true;
    database.createDB = true;
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 2283 ];
}
