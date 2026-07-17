{ config, pkgs, lib, user, hostName ? null, ... }:

{
  imports = [ ];

  # ── Networking / hostname ─────────────────────────────────────────────────
  # Unlike Darwin (which can inherit whatever Computer Name macOS setup gave
  # it), a fresh NixOS install has no prior name to preserve, so this always
  # sets one — "nixos" if you don't override it via mkNixosSystem's hostName.
  networking.hostName = if hostName != null then hostName else "nixos";
  networking.networkmanager.enable = true;
  # Explicit fallback DNS: DHCP-provided DNS wasn't resolving reliably on
  # first install (raw-IP connectivity worked, hostname resolution didn't).
  # These take effect regardless of what DHCP does or doesn't hand out.
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # ── Keyboard: Norwegian, no dead keys ──────────────────────────────────────
  # console.keyMap affects the TTY you're on right now; the xkb settings
  # apply once/if a graphical session (X11/Wayland) is added later.
  console.keyMap = "no";
  services.xserver.xkb = {
    layout = "no";
    variant = "nodeadkeys";
  };

  # ── User ───────────────────────────────────────────────────────────────────
  # initialPassword only matters for the very first local login before
  # Tailscale/SSH keys are set up — change it immediately with `passwd`.
  users.users.${user} = {
    isNormalUser = true;
    initialPassword = "nixos";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "input" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # ── Boot loader ──────────────────────────────────────────────────────────
  # systemd-boot, not GRUB: this machine dual-boots Windows on the SAME disk,
  # sharing one EFI System Partition. canTouchEfiVariables lets NixOS add its
  # own boot entry without touching Windows' or Kubuntu's existing ones.
  # IMPORTANT: if Secure Boot is enabled in the BIOS, the NVIDIA kernel module
  # below will fail to load (unsigned) — disable Secure Boot in the BIOS
  # before installing, unless you deliberately want to set up lanzaboote.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20; # keep plenty of rollback history
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # newest hardware support for i5-14400f + Blackwell GPU

  # ── Nix settings ───────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" user ];
  };
  nixpkgs.config.allowUnfree = true; # required for NVIDIA driver/CUDA

  # ── Firmware ─────────────────────────────────────────────────────────────
  # The live installer ISO bundles full firmware, so wifi/bluetooth (Intel
  # iwlwifi/ibt) work during install regardless of this setting — but a
  # freshly installed system does NOT get it unless set explicitly, which is
  # why wifi disappeared after the first real boot. Set here so it's never
  # missed again on a reinstall.
  hardware.enableRedistributableFirmware = true;

  # ── GPU: NVIDIA (RTX 5060 Ti / Blackwell) ──────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam/Proton
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # NVIDIA's recommended kernel module for Turing+ (incl. Blackwell)
    # Blackwell is very new — "latest" tracks the newest driver builds most
    # likely to support it. Once "stable" catches up, switching is safer.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    powerManagement.enable = false; # desktop, not a laptop
    nvidiaSettings = true;
  };

  # ── Remote compute: Tailscale + SSH ─────────────────────────────────────────
  # This machine's primary purpose — SSH in over Tailscale to use the GPU
  # remotely instead of owning a second, more expensive laptop.
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.checkReversePath = "loose"; # needed if you ever use subnet routes/exit node

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true; # convenience for first login only —
    # once your SSH key is copied over and confirmed working, consider
    # setting this to false so only key auth is accepted over Tailscale.
  };

  # ── Docker + GPU passthrough (occasional containerized ML workloads) ──────
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  # ── Gaming (secondary priority, nice to have) ───────────────────────────────
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
  };
  programs.gamemode.enable = true;

  # ── Locale / time zone ──────────────────────────────────────────────────────
  # TODO: set your actual time zone, e.g. "Europe/Oslo".
  # time.timeZone = "Europe/Oslo";

  # ── State version ───────────────────────────────────────────────────────────
  # Set once at install time, matching home.stateVersion in home/default.nix.
  # Per NixOS convention, do NOT bump this on upgrades — it's not a version
  # pin, it's a marker of the format this system was originally created with.
  system.stateVersion = "25.05";
}
