# Sash setup

Use the existing NixOS revision and hardware configuration. Keep the installed
state version and Tailscale identity. Manage SSH, Tailscale, lid behavior, Rust
tools, the persistent T3 user service, and Forgejo in Nix modules.

- Build before activation and preserve the known working generation and original files.
- Disable lid-triggered and idle sleep on both AC and battery.
- Start T3 under ash's lingering user manager with Nix's Linux binary compatibility.
- Keep T3 on loopback port 3773, Tailscale HTTPS 443, and private per-device pairing. Unlink and disable the public Connect tunnel.
- Use sash as the OS and Tailscale hostname. Migrate the old nixos client route.
- Serve Forgejo only through Tailscale HTTPS 8443 and tailnet SSH 2222.
- Use SQLite, Git LFS, disabled registration, a private default, and daily local dumps.
- Create the ash administrator and register public keys for both clients.
- Verify native Rust builds, linting, formatting, and language-server availability.
- Verify Git push and clone from the Mac and from sash, service restart, and reboot.
- Publish only configuration, documentation, and verification scripts to GitHub.
  Credentials, application databases, and private keys stay outside the repository.

The repo on sash lives at /home/ash/ash-sash. /etc/nixos points to it after deployment.
The flake pins nixpkgs to the revision already used by this machine.
