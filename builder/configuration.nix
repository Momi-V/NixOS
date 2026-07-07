# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set higher uLimit
  systemd.settings.Manager.DefaultLimitNOFILE = "65536:1048576";
  systemd.user.extraConfig = "DefaultLimitNOFILE=65536:1048576";

  networking.hostName = "builder"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "de";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  #services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  #services.displayManager.sddm.enable = true;
  #services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # General user environment
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = 1;
  };
  environment.shellAliases = {
    nixconf = "sudo nano /etc/nixos/configuration.nix";
    nixrb = "sudo nixos-rebuild switch";
    xfind = "find -xdev -iname";
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."momi" = {
    isNormalUser = true;
    description = "momi";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate github-desktop
      btop tmux
    ];
  };

  # Nix internal Options
  nix.settings = {
    # Nix Experimental
    experimental-features = "nix-command flakes";
    # Nix Limit parallel build
    max-jobs = 16;
    cores = 16;
  };

  # Allow unfree Software and add unstable channnel
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim nano # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget curl
    htop cifs-utils
    git nix-search-cli niv
  ];

  # List services that you want to enable:
  # QEMU guest
  services.qemuGuest.enable = true;

  # FHS compatibility
  services.envfs.enable = true;
  programs.nix-ld.enable = true;

  # zRam zwap
  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;

  # Nix stuff
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    persistent = true;
    allowReboot = false;
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
    persistent = true;
  };

  #nix.gc = {
  #  automatic = true;
  #  dates = "weekly";
  #  persistent = true;
  #  options = "--delete-older-than 30d";
  #};

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
