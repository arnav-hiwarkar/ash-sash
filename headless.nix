{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "sash-rebuild";
      runtimeInputs = [ pkgs.systemd pkgs.sudo ];
      text = builtins.readFile ./scripts/rebuild.sh;
    })
  ];
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    IdleAction = "ignore";
  };
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };
}
