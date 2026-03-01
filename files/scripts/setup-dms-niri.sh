#!/usr/bin/env bash
set -oue pipefail

if ! command -v dms >/dev/null 2>&1; then
  echo "dms not found, skipping DMS setup"
  exit 0
fi

install -d -m 0755 /etc/skel
install -d -m 0755 /etc/skel/.config

HOME=/etc/skel XDG_CONFIG_HOME=/etc/skel/.config dms setup

install -d -m 0755 /etc/skel/.config/systemd/user/niri.service.wants
if [ -f /usr/lib/systemd/user/dms.service ]; then
  ln -sf /usr/lib/systemd/user/dms.service /etc/skel/.config/systemd/user/niri.service.wants/dms.service
fi
