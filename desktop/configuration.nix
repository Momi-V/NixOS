# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
    sources = import /root/nix/sources.nix;
    lanzaboote = import sources.lanzaboote { inherit pkgs; };
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
  boot.kernelModules = [ "ntsync" ];
  boot.kernelParams = [ "zswap.enabled=1" "zswap.max_pool_percent=50" "zswap.compressor=zstd" "zswap.zpool=zsmalloc" "video=DP-2:e" "drm.edid_firmware=DP-2:edid/edid.bin" ];

  # Set higher uLimit
  systemd.settings.Manager.DefaultLimitNOFILE = "65536:1048576";
  systemd.user.extraConfig = "DefaultLimitNOFILE=65536:1048576";

  hardware.firmware = [(
    pkgs.runCommand "edid.bin" { } ''
      mkdir -p $out/lib/firmware/edid
      cp ${./modules/edid_32.bin} $out/lib/firmware/edid/edid.bin
    ''
  )];

  # DaVinci Resolve UDEV
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="096e", MODE="0664", GROUP="users", TAG+="uaccess"
  '';

  ## POWER
  services.power-profiles-daemon.enable = true;
  powerManagement = {
    enable = true;
  };

  # Networking
  networking.hostName = "EmberFlake"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.interfaces.enp7s0.wakeOnLan.enable = true; # Turn on WoL

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  # time.hardwareClockInLocalTime = true; # RTC local time

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "de";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable HW Acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;

  # KDE Plasma Desktop
  # services.xserver.enable = true; # optional
  services.displayManager.plasma-login-manager.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;
  programs.dconf.enable = true;

  # XDG Portals (Screenshare, etc.)
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "kde" ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-termfilechooser
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
  };

  # Sunshine for remote Desktop
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.system-config-printer.enable = true;

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

  # General user environment
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = 1;
    PROTON_ENABLE_WAYLAND=1;
    PROTON_ENABLE_HDR=1;
    MANGOHUD=1;
  };
  environment.shellAliases = {
    nixconf = "sudo nano /etc/nixos/configuration.nix";
    nixrb = "sudo nixos-rebuild switch";
    xfind = "find -xdev -iname";
  };

  # NAS Share mount
  fileSystems."/home/momi/net" = {
    device = "//truenas.lan/net/";
    fsType = "cifs";
    options = [
      "credentials=/home/momi/netsmb.login"
      "mfsymlinks,echo_interval=15" "uid=1000,gid=100"
      "x-systemd.automount,noauto,nofail,x-systemd.idle-timeout=60,x-systemd.mount-timeout=15"
    ];
  };

  # Enable Steam and related services
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession.enable = true; # Use the gamescope compositor, enables resolution upscaling and stretched aspect ratios
    extraCompatPackages = [ pkgs.proton-ge-bin ]; # Install Proton-GE
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.momi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" "video" "render" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      bitwarden-desktop nextcloud-client protonmail-bridge-gui rnote
      chromium firefox discord spotify vlc
      github-desktop libreoffice thunderbird
      pkgsRocm.blender davinci-resolve-studio
      amdgpu_top btop fastfetch screen mission-center
      btrfs-assistant kdePackages.filelight
      kdePackages.kcalc kdePackages.kcharselect meld
      virt-manager docker-compose easyeffects
      cemu winetricks mangohud lmstudio
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
    permittedInsecurePackages = [
      "electron-39.8.10"
    ];
  };

  # Virtualization
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    nano vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    curl dig wget
    htop cifs-utils
    git sbctl niv nix-search-cli
    gparted-full kdePackages.partitionmanager
    btrfs-progs compsize e2fsprogs exfatprogs ntfsprogs-plus xfsprogs
    wineWow64Packages.stableFull
    hunspell hunspellDicts.de_DE hunspellDicts.en_US-large
  ];

  # List services that you want to enable:
  # Btrfs scrub
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # Snapper config
  services.snapper.persistentTimer = true;
  services.snapper.configs = {
    home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ "momi" ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 37;
      TIMELINE_LIMIT_DAILY = 9;
      TIMELINE_LIMIT_WEEKLY = 0;
      TIMELINE_LIMIT_MONTHLY = 0;
      TIMELINE_LIMIT_QUARTERLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

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
