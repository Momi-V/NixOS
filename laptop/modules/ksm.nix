{ config, lib, pkgs, ... }:

let
  cfg = config.pongo.ksm;
in

{
  options.pongo.ksm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the pongo KSM helper module.";
    };

    forceAllProcesses = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "If true, override systemd with a patched build enabling memory KSM behavior by default.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.ksm.enable = true;

    systemd = {
      tmpfiles.rules = [
        "w /sys/kernel/mm/ksm/advisor_mode - - - - scan-time"
      ];
    }
    // lib.optionalAttrs cfg.forceAllProcesses {
      package = pkgs.systemd.overrideAttrs (prev: {
        patches = prev.patches ++ [ ./memoryksm-on-by-default.patch ];
      });
    };
  };
}
