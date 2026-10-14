#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:/run/current-system/sw/bin:$PATH"
test "$(hostname)" = sash
for unit in sshd tailscaled forgejo forgejo-tailscale; do
  systemctl is-active --quiet "$unit"
  systemctl is-enabled --quiet "$unit"
done
systemctl --user is-active --quiet t3code
systemctl --user is-enabled --quiet t3code
test "$(loginctl show-user ash -p Linger --value)" = yes
for setting in HandleLidSwitch HandleLidSwitchExternalPower HandleLidSwitchDocked; do
  grep -qx "$setting=ignore" /etc/systemd/logind.conf
done
tailscale status --json | jq -e '.BackendState == "Running" and (.Self.DNSName | startswith("sash."))' >/dev/null
curl -fsS http://127.0.0.1:3773/.well-known/t3/environment | jq -e '.environmentId | length > 0' >/dev/null
curl -fsS http://127.0.0.1:3000/api/healthz >/dev/null
printf 'PASS: hostname, boot services, lid settings, Tailscale, T3, and Forgejo\n'
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cd "$workdir"
cargo init --quiet --name sash_rust_check
cat > src/main.rs <<'RS'
fn main() {
    println!("sash rust works");
}
RS
cargo fmt --check
cargo clippy --quiet -- -D warnings
test "$(cargo run --quiet)" = 'sash rust works'
rust-analyzer --version
printf 'PASS: Rust compilation, execution, formatting, linting, and language server\n'
