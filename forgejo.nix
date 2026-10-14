{ pkgs, ... }:
let
  domain = "sash.tail437275.ts.net";
in
{
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    database.type = "sqlite3";
    lfs.enable = true;
    settings = {
      DEFAULT.APP_NAME = "Sash Git";
      server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}:8443/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3000;
        START_SSH_SERVER = true;
        SSH_DOMAIN = domain;
        SSH_PORT = 2222;
        SSH_LISTEN_HOST = "0.0.0.0";
        SSH_LISTEN_PORT = 2222;
        BUILTIN_SSH_SERVER_USER = "git";
      };
      service = {
        DISABLE_REGISTRATION = true;
        REQUIRE_SIGNIN_VIEW = true;
      };
      session.COOKIE_SECURE = true;
      repository.DEFAULT_PRIVATE = "private";
      "repository.upload".ENABLED = true;
    };
    dump = {
      enable = true;
      interval = "daily";
      age = "14d";
    };
  };
  systemd.timers.forgejo-dump.timerConfig.Persistent = true;
  systemd.services.forgejo-tailscale = {
    description = "Forgejo HTTPS on Tailscale";
    wantedBy = [ "multi-user.target" ];
    wants = [
      "tailscaled.service"
      "forgejo.service"
      "network-online.target"
    ];
    after = [
      "tailscaled.service"
      "forgejo.service"
      "network-online.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=8443 http://127.0.0.1:3000";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
