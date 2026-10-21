{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./development.nix
    ./headless.nix
    ./t3.nix
    ./forgejo.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };
  networking.hostName = "sash";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
  };
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = [
      "--hostname=sash"
      "--operator=ash"
    ];
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-initial-setup.enable = false;
  services.displayManager = {
    gdm = {
      enable = true;
      autoSuspend = false;
    };
    defaultSession = "gnome";
    autoLogin = {
      enable = true;
      user = "ash";
    };
  };
  hardware.graphics.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_IN";
  users.users.ash = {
    isNormalUser = true;
    description = "Arnav";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    linger = true;
  };
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      nspr
      nss
      atk
      at-spi2-atk
      cups
      dbus
      libdrm
      expat
      libxkbcommon
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      mesa
      pango
      cairo
      alsa-lib
    ];
  };
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    git-lfs
    neovim
    htop
    fd
    ripgrep
    cloc
    speedtest-cli
    fzf
    yazi
    curl
    unzip
    usbutils
    pciutils
    gh
    tmux
    jq
    forgejo
    opencode
    fastfetch
  ];
  system.stateVersion = "26.05";
}
