#!/usr/bin/env bash

set -euo pipefail

UPSTREAM_REPO="https://github.com/end-4/dots-hyprland.git"
WORKDIR="$(mktemp -d)"

cleanup() {
	rm -rf "${WORKDIR}"
}
trap cleanup EXIT

sync_config_dir() {
	local name="$1"
	local source_dir="${WORKDIR}/dots-hyprland/dots/.config/${name}"
	local target_dir="/etc/xdg/${name}"

	if [[ -d "${source_dir}" ]]; then
		mkdir -p "${target_dir}"
		rsync -a --delete "${source_dir}/" "${target_dir}/"
	fi
}

echo "[setup] Cloning ${UPSTREAM_REPO}..."
git clone --depth 1 "${UPSTREAM_REPO}" "${WORKDIR}/dots-hyprland"

echo "[setup] Copying required configs into /etc/xdg..."
mkdir -p /etc/xdg

for dir in hypr quickshell matugen kitty fish fontconfig wlogout qt5ct qt6ct; do
	sync_config_dir "${dir}"
done

echo "[setup] Copying shared assets into /usr/share..."
if [[ -d "${WORKDIR}/dots-hyprland/dots/.local/share" ]]; then
	mkdir -p /usr/share
	rsync -a "${WORKDIR}/dots-hyprland/dots/.local/share/" /usr/share/
fi

echo "[setup] Ensuring Hyprland custom include files exist..."
mkdir -p /etc/xdg/hypr/custom
for conf in env execs general keybinds rules; do
	if [[ ! -f "/etc/xdg/hypr/custom/${conf}.conf" ]]; then
		touch "/etc/xdg/hypr/custom/${conf}.conf"
	fi
done

echo "[setup] Rewriting hardcoded home config paths to system-level paths..."
while IFS= read -r -d '' file; do
	sed -i \
		-e 's|~/.config/hypr|/etc/xdg/hypr|g' \
		-e 's|~/.config/quickshell|/etc/xdg/quickshell|g' \
		"${file}"
done < <(find /etc/xdg/hypr -type f -print0)

find /etc/xdg/hypr -type f -name '*.sh' -exec chmod 0755 {} +

echo "[setup] System-level config copy complete."
