#!/usr/bin/env bash
#
# Install kanata config + systemd unit into system paths.
#
# Why copy and not symlink:
#   On Bazzite (SELinux enforcing), systemd refuses to read unit files
#   or execute binaries whose canonical path lives under /home — the
#   user_home_t context is wrong for system services. We copy and then
#   restorecon so the files get the correct system context.
#
# Run after editing config.kbd or kanata.service in this directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
  echo "Re-running with sudo..."
  exec sudo "$0" "$@"
fi

install -d -m 755 /etc/kanata

install -m 644 "$SCRIPT_DIR/config.kbd"     /etc/kanata/config.kbd
install -m 644 "$SCRIPT_DIR/kanata.service" /etc/systemd/system/kanata.service

restorecon -v /etc/kanata/config.kbd
restorecon -v /etc/systemd/system/kanata.service

systemctl daemon-reload

if systemctl is-enabled --quiet kanata.service; then
  systemctl restart kanata.service
  echo "kanata restarted."
else
  systemctl enable --now kanata.service
  echo "kanata enabled and started."
fi

systemctl --no-pager status kanata.service
