{ lib, pkgs, ... }:
{
  systemd.user.services.t3code = {
    description = "T3 Code server";
    wantedBy = [ "default.target" ];
    unitConfig = {
      StartLimitIntervalSec = 0;
      ConditionUser = "ash";
    };
    environment = {
      PATH = lib.mkForce "/home/ash/.local/bin:/home/ash/.local/npm/bin:/run/wrappers/bin:/home/ash/.nix-profile/bin:/etc/profiles/per-user/ash/bin:/run/current-system/sw/bin";
      T3CODE_HOME = "/home/ash/.t3";
      T3_BOOT_SERVICE_UNIT = "t3code.service";
      T3CODE_HOST = "127.0.0.1";
      T3CODE_PORT = "3773";
      T3CODE_TAILSCALE_SERVE = "true";
      T3CODE_TAILSCALE_SERVE_PORT = "443";
      NIX_LD = "/run/current-system/sw/share/nix-ld/lib/ld.so";
      NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
    };
    serviceConfig = {
      Type = "simple";
      TimeoutStartSec = "infinity";
      ExecStartPre = pkgs.writeShellScript "t3-wait-online" ''
        until ${pkgs.systemd}/bin/timedatectl show -p NTPSynchronized --value | ${pkgs.gnugrep}/bin/grep -qx yes \
          && ${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq -e ' .BackendState == "Running" ' >/dev/null; do
          ${pkgs.coreutils}/bin/sleep 2
        done
      '';
      WorkingDirectory = "/home/ash";
      ExecStart = "/home/ash/.local/bin/t3 __service-launcher";
      KillMode = "mixed";
      OOMPolicy = "continue";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
