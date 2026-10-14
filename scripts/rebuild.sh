#!/usr/bin/env bash
set -euo pipefail
if (( $# != 0 )); then
  echo "Usage: sash-rebuild" >&2
  exit 2
fi
sudo systemd-run --unit=sash-rebuild --collect --no-block \
  --description="Rebuild sash independently of SSH and T3" \
  --setenv=SUDO_UID="$(id -u ash)" \
  --setenv=PATH=/run/wrappers/bin:/run/current-system/sw/bin \
  --property=Type=exec \
  --property=WorkingDirectory=/home/ash/ash-sash \
  --property=StandardOutput=journal \
  --property=StandardError=journal \
  /run/current-system/sw/bin/nixos-rebuild switch \
  --flake /home/ash/ash-sash#sash
printf '%s\n' \
  'Rebuild started independently of this terminal.' \
  'Watch: sudo journalctl -fu sash-rebuild.service' \
  'Verify after completion: ~/ash-sash/scripts/verify-host.sh'
