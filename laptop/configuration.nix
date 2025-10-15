# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
    sources = import /root/nix/sources.nix;
    lanzaboote = import sources.lanzaboote;
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      lanzaboote.nixosModules.lanzaboote
    ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  # Lanzaboote
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Use latest Kernel and zSwap
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "zswap.enabled=1" "zswap.max_pool_percent=50" "zswap.compressor=zstd" "zswap.zpool=zsmalloc" ];

  ## POWER
  powerManagement = {
    enable = true;
    # cpuFreqGovernor = "schedutil";
  };

  # services.power-profiles-daemon.enable = true;
  # services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.settings = {
  #   battery = {
  #     governor = "powersave";
  #     turbo = "never";
  #    };
  #    charger = {
  #      governor = "performance";
  #      turbo = "auto";
  #    };
  # };

  networking.hostName = "AshFlake"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Hostname resolution over VPN
  # networking.networkmanager.appendNameservers = [ "10.11.1.1" ]; # Overwritten by Tailscale
  # environment.etc = {
  #   "resolv.conf".text = "nameserver 10.11.1.1\n";
  # };
  # networking.extraHosts =
  # ''
  #   10.11.1.1 unifi
  # '';

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Thunderbolt
  services.hardware.bolt.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  time.hardwareClockInLocalTime = true; # RTC local time

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "de";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable HW Acceleration
  environment.variables.AMD_VULKAN_ICD = "RADV";
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # KDE Plasma Desktop
  services.xserver.enable = true; # optional
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.autoNumlock = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.dconf.enable = true;

  # Fingerprint Reader
  services.fprintd.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    # Uncomment the following line if you want to use JACK applications
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # General user environment
  environment.shellAliases = {
    nixconf = "sudo nano /etc/nixos/configuration.nix";
    nixrb = "sudo nixos-rebuild switch";
  };

  # Enable Steam and related services
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.momi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      bitwarden nextcloud-client moonlight-qt
      firefox github-desktop discord vlc
      libreoffice thunderbird
      btop fastfetch
      btrfs-assistant screen
      virt-manager docker-compose
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

  # Virtualization
  # virtualisation.libvirtd.enable = true;
  # virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.docker.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    nano vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    curl wget
    htop cifs-utils
    git sbctl niv nix-search-cli
    aspell aspellDicts.de aspellDicts.en aspellDicts.en-computers aspellDicts.en-science
    #unstable.fosrl-olm
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Btrfs scrub
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # Tailscale
  # services.tailscale.enable = true;
  # services.tailscale.useRoutingFeatures = "client";

  # Proton Mail
  # services.protonmail-bridge.enable = true;

  # Olm systemd
  # systemd.services.olm-vpn = {
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   description = "Olm VPN client.";
  #   path = [ pkgs.iproute2 ];
  #   serviceConfig = {
  #     Restart = "always";
  #     User = "root";
  #     EnvironmentFile = "/home/momi/Olm.conf";
  #     ExecStart = "${pkgs.unstable.fosrl-olm}/bin/olm";
  #   };
  # };

  # FHS compatibility
  services.envfs.enable = true;
  programs.nix-ld.enable = true;

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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    persistent = true;
    options = "--delete-older-than 30d";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
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
