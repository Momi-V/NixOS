# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  # Use latest Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelParams = [ "nomodeset" ];

  # Use zRam
  zramSwap.enable = true;
  zramSwap.algorithm = zstd;
  zramSwap.memoryPercent = 66;


  # Networking
  networking.hostName = "NovaFlake"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # networking.networkmanager.settings.connection.autoconnect = true; # Make sure autoconnect is active.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  # time.hardwareClockInLocalTime = true; # RTC local time

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # General user environment
  environment.shellAliases = {
    nixconf = "sudo nano /etc/nixos/configuration.nix";
    nixrb = "sudo nixos-rebuild switch";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      btop fastfetch screen gh
    ];
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

  services.cockpit = {
    enable = true;
    openFirewall = true;
    allowed-origins = [
      "https://novaflake.lan:9090"  # The URL clients will connect from in the browser (for CORS config)
    ];
    # settings = {
    #   WebService = {
    #     AllowUnencrypted = true;
    #     ProtocolHeader = "X-Forwarded-Proto";  # Specifies the request goes through a reverse proxy
    #   };
    # };
  };

  # Virtualization
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.docker.enable = true;
  # Remap Docker data root
  virtualisation.docker.daemon.settings = {
    data-root = "/mnt/nasdata/system/docker";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    curl wget dnsutils
    docker-compose htop
    git nix-search-cli
  ];

  # System services.
  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  # FHS compatibility
  services.envfs.enable = true;
  programs.nix-ld.enable = true;

  # Nix stuff
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    persistent = true;
    allowReboot = true;
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
    persistent = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    persistent = true;
    options = "--delete-older-than 30d";
  };

  # Enable cron service
  # services.cron = {
  #   enable = true;
  #   systemCronJobs = [
  #     "*/1 * * * * root . /etc/profile; /var/dyndns/dyndns.bash"
  #   ];
  # };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 3552 9443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
