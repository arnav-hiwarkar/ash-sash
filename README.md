# Sash

Headless NixOS laptop, T3 Code host, Rust development machine, and private Forgejo.

| Service | Address |
| --- | --- |
| SSH | `ssh sash` or `ssh ash@100.70.118.124` |
| T3 over Tailscale | `https://sash.tail437275.ts.net/` |
| Forgejo | `https://sash.tail437275.ts.net:8443/` |
| Forgejo Git SSH | `ssh://git@sash.tail437275.ts.net:2222/ash/REPO.git` |

Both devices must be connected to the same Tailscale network for these addresses.
Forgejo's HTTP backend listens only on localhost. Its SSH port is allowed through
Tailscale's trusted interface, and is blocked on other network interfaces.

The configuration repository is `/home/ash/ash-sash` on the server. `/etc/nixos`
points to it. The locked flake uses the machine's existing nixpkgs revision.

## Apply changes

```sh
cd ~/ash-sash
git pull --ff-only
sudo nixos-rebuild build --flake .#sash
sash-rebuild
sudo journalctl -fu sash-rebuild.service
# After the log reports completion, press Ctrl+C and verify:
./scripts/verify-host.sh
```

`sash-rebuild` runs the switch in a separate system service with logs in the
journal. The rebuild continues if SSH disconnects or T3 restarts. Use it when
applying changes from a T3 terminal on sash: a foreground rebuild that restarts
T3 can lose its terminal and fail before bringing T3 back. Before this helper is
installed, use `bash ~/ash-sash/scripts/rebuild.sh`.

If T3 is offline but SSH works, restore it from your Mac:

```sh
ssh sash 'systemctl --user start t3code.service'
```

Keep the existing pairing. Both clients need Tailscale connected and the route
`https://sash.tail437275.ts.net/`.

The lid can remain closed on AC or battery. Suspend and hibernation are disabled.
SSH, Tailscale, Forgejo, and T3 start without logging in. T3 runs as `ash` under a
lingering user manager. T3 waits for clock synchronization and Tailscale before
starting, so booting with an incorrect hardware clock cannot invalidate its
cloud credentials. Its Nix-managed unit uses the installed `~/.local/bin/t3`
binary and preserves the existing `~/.t3` application data and Connect identity.

## T3 clients

This host uses private Tailscale pairing. T3 Connect's public cloud tunnel is
unlinked and disabled. Keep Tailscale connected on the Mac and phone, using the
same tailnet account as sash.

1. In T3's connection settings, remove the old T3 Connect route for this machine.
   Remove the saved `https://nixos.tail437275.ts.net/` route too.
2. On sash, generate a private one-time pairing link for each client:

```sh
t3 pair --tailscale --label "Mac"
t3 pair --tailscale --label "Phone"
```

3. On the Mac, use Settings → Connections → Add environment and paste its link.
   On the phone, use Settings → Environments → Add environment and paste its link.
4. Confirm the route uses `https://sash.tail437275.ts.net/`.

Use a separate link per device. Pairing links are credentials. Clients remain
paired after the one-time link expires. If you disconnect a client from Tailscale,
that client must lose access to sash.

```sh
systemctl --user status t3code
journalctl --user -u t3code -n 50
t3 connect status
```

`connect status` must show disabled exposure. Do not run `t3 connect` or enable
its switch in the UI if you want this host to stay private to Tailscale.
The T3 CLI can report its service as not installed because Nix manages the unit.
Use `systemctl --user status t3code` to inspect the actual service.

The Nix-managed service takes effect after removing the old manually installed
unit from `~/.config/systemd/user`. Reinstalling T3's own service can create a
local override, so inspect `systemctl --user cat t3code` if behavior changes.

## Rust

Rust, Cargo, rustfmt, Clippy, rust-analyzer, standard-library sources, debuggers,
C/C++ compilers, CMake, pkg-config, OpenSSL, and libclang are installed.
`cargo-nextest`, `cargo-audit`, and `cargo-watch` are also available.

For a project environment with native dependency discovery:

```sh
nix develop ~/ash-sash
cargo build
cargo fmt --check
cargo clippy -- -D warnings
cargo test
```

The flake dev shell is for x86_64 Linux on sash. The Mac connects by SSH to use it.

## Forgejo

The administrator is `ash`. Passwords and tokens are stored outside this repo.
Registration is disabled, repositories default to private, and Git LFS is enabled.
Both machines have the SSH aliases `forgejo` and `sash-git`. Full SSH clone URLs
from the web interface also select the registered key. The old Mac alias
`forgejo` is available as `forgejo-arch`.

```sh
git clone forgejo:ash/ash-sash.git
```

To publish a different existing repo, create an empty repo in Forgejo, then:

```sh
git remote add forgejo forgejo:ash/REPO.git
git push forgejo HEAD
```

Follow [the Forgejo guide](docs/forgejo.md) for creating projects, publishing
existing repositories, and using both GitHub and Forgejo. SSH reference entries
are in `ssh/mac.conf` and `ssh/sash.conf`. No CI runner is configured.

Forgejo's state, repositories, and SQLite database live in `/var/lib/forgejo`.
Daily dumps live in `/var/lib/forgejo/dump` and are retained for 14 days. These
backups are on the same disk, so copy them elsewhere for protection against disk
failure. The dump timer can be checked with `systemctl status forgejo-dump.timer`.

## Recovery

Original Nix files and T3 units are backed up under
`/var/backups/sash/2026-10-14/`. The known working generation is recorded in
`working-generation` there. Older generations remain in the GRUB menu.

```sh
sudo nixos-rebuild switch --rollback
```

A reboot is needed to use a rolled-back kernel. Check network access before
rebooting. Do not copy private keys, Tailscale state, T3 data, or Forgejo data into
this public configuration repository.
