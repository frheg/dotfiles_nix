{ lib, ... }:

{
  # ── PLACEHOLDER ─────────────────────────────────────────────────────────
  # This file only exists so `nix flake check` can evaluate the
  # nixosConfigurations.nixos-workstation output before the machine is
  # actually installed.
  #
  # After partitioning, run on the target machine (from the NixOS installer):
  #   nixos-generate-config --root /mnt
  # Then REPLACE THE ENTIRE CONTENTS of this file with the resulting
  # /mnt/etc/nixos/hardware-configuration.nix (disk UUIDs, filesystem types,
  # CPU microcode, kernel modules — all genuinely machine-specific, unlike
  # everything in hosts/nixos-workstation.nix which is meant to be shared
  # across any NixOS machine of this role).
  boot.loader.grub.enable = lib.mkDefault false;

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
