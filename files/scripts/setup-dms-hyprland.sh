#!/usr/bin/env bash
set -oue pipefail

if ! command -v dms >/dev/null 2>&1; then
  echo "dms not found, skipping DMS setup"
  exit 0
fi

install -d -m 0755 /etc/skel
install -d -m 0755 /etc/skel/.config

HOME=/etc/skel XDG_CONFIG_HOME=/etc/skel/.config dms setup

install -d -m 0755 /etc/skel/.config/systemd/user
cat >/etc/skel/.config/systemd/user/hyprland-session.target <<'EOF'
[Unit]
Description=Hyprland Session Target
Requires=graphical-session.target
After=graphical-session.target
EOF

install -d -m 0755 /etc/skel/.config/systemd/user/hyprland-session.target.wants
if [ -f /usr/lib/systemd/user/dms.service ]; then
  ln -sf /usr/lib/systemd/user/dms.service /etc/skel/.config/systemd/user/hyprland-session.target.wants/dms.service
fi

install -d -m 0755 /etc/skel/.config/hypr
touch /etc/skel/.config/hypr/hyprland.conf

if ! grep -q "dbus-update-activation-environment --systemd --all" /etc/skel/.config/hypr/hyprland.conf; then
  printf '\nexec-once = dbus-update-activation-environment --systemd --all\n' >> /etc/skel/.config/hypr/hyprland.conf
fi

if ! grep -q "systemctl --user start hyprland-session.target" /etc/skel/.config/hypr/hyprland.conf; then
  printf 'exec-once = systemctl --user start hyprland-session.target\n' >> /etc/skel/.config/hypr/hyprland.conf
fi
