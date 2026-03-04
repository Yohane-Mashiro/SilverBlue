#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_REPO_URL="https://github.com/end-4/dots-hyprland.git"
DOTS_CLONE_DIR="/tmp/dots-hyprland"

if [[ $EUID -ne 0 ]]; then
	echo "請使用 root 權限執行（blue-build 構建環境通常已是 root）。" >&2
	exit 1
fi

PLASMA_SESSION_FILE="/usr/share/wayland-sessions/plasma.desktop"
if [[ -f "$PLASMA_SESSION_FILE" ]]; then
	rm -f "$PLASMA_SESSION_FILE"
	echo "已移除：$PLASMA_SESSION_FILE"
fi

echo "正在 clone: $DOTS_REPO_URL"
git clone --depth 1 "$DOTS_REPO_URL" "$DOTS_CLONE_DIR"

REPO_ROOT="$DOTS_CLONE_DIR"

cd "$REPO_ROOT"

source ./sdata/lib/environment-variables.sh
source ./sdata/lib/functions.sh

OS_DISTRO_ID="fedora"
OS_DISTRO_ID_LIKE="fedora"
OS_GROUP_ID="fedora"
INSTALL_VIA_NIX=false

SKIP_ALLDEPS=true
SKIP_ALLSETUPS=false
SKIP_ALLGREETING=false
SKIP_BACKUP=true
ask=false

# 安裝完整主題配置（不跳過 misc/quickshell/fish/fontconfig）
SKIP_MISCCONF=false
SKIP_QUICKSHELL=false
SKIP_FISH=false
SKIP_FONTCONFIG=false
SKIP_HYPRLAND=false
FONTSET_DIR_NAME=""
ILLOGICAL_IMPULSE_VIRTUAL_ENV="${ILLOGICAL_IMPULSE_VIRTUAL_ENV:-}"

EXPERIMENTAL_FILES_SCRIPT=false
INSTALL_FIRSTRUN=false

# 新使用者預設配置目錄（/etc/skel）
XDG_CONFIG_HOME="/etc/skel/.config"
XDG_DATA_HOME="/etc/skel/.local/share"
XDG_BIN_HOME="/etc/skel/.local/bin"
XDG_CACHE_HOME="/tmp/ii-cache"
XDG_STATE_HOME="/tmp/ii-state"

# 避免在系統配置目錄生成安裝狀態檔
DOTS_CORE_CONFDIR="/tmp/ii-build"
INSTALLED_LISTFILE="${DOTS_CORE_CONFDIR}/installed_listfile"
FIRSTRUN_FILE="${DOTS_CORE_CONFDIR}/installed_true"
BACKUP_DIR="/tmp/ii-backup"

if [[ ! -f ./sdata/subcmd-install/3.files.sh ]]; then
	echo "找不到檔案安裝腳本: ./sdata/subcmd-install/3.files.sh" >&2
	exit 1
fi

echo "以 setup 邏輯執行主題安裝（fedora, skip deps/setups）"
source ./sdata/subcmd-install/3.files.sh

POST_INSTALL_SCRIPT="/usr/bin/hyprtheme-default"
POST_INSTALL_WRAPPER="/usr/local/bin/hyprtheme-default"
POST_INSTALL_MARKER_DIR="/var/lib/silverblue-hypr-theme"

mkdir -p "$(dirname "$POST_INSTALL_SCRIPT")"
cat > "$POST_INSTALL_SCRIPT" <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

MARKER_DIR="/var/lib/silverblue-hypr-theme"
SKEL_CONFIG_DIR="/etc/skel/.config"
SKEL_DATA_DIR="/etc/skel/.local/share"

sync_user() {
	local target_user="$1"
	local marker_file="${MARKER_DIR}/${target_user}.synced"
	local target_home

	if [[ -f "$marker_file" ]]; then
		return 0
	fi

	if ! id "$target_user" >/dev/null 2>&1; then
		echo "[post-install] 使用者不存在，略過：$target_user"
		return 0
	fi

	target_home="$(getent passwd "$target_user" | cut -d: -f6)"
	if [[ -z "$target_home" ]] || [[ ! -d "$target_home" ]]; then
		echo "[post-install] 找不到使用者家目錄，略過：$target_user"
		return 0
	fi

	mkdir -p "$target_home/.config"
	mkdir -p "$target_home/.local/share"

	if [[ -d "$SKEL_CONFIG_DIR" ]]; then
		rsync -a "$SKEL_CONFIG_DIR/" "$target_home/.config/"
	fi

	if [[ -d "$SKEL_DATA_DIR" ]]; then
		rsync -a "$SKEL_DATA_DIR/" "$target_home/.local/share/"
	fi

	chown -R "$target_user:$target_user" "$target_home/.config" "$target_home/.local/share"

	mkdir -p "$MARKER_DIR"
	touch "$marker_file"

	echo "[post-install] 已同步主題配置到 $target_user"
}

if [[ $# -gt 0 ]]; then
	sync_user "$1"
	exit 0
fi

while IFS=: read -r username _ uid _ _ home shell; do
	if [[ "$uid" -lt 1000 ]]; then
		continue
	fi
	if [[ ! -d "$home" ]]; then
		continue
	fi
	case "$shell" in
		""|"/usr/sbin/nologin"|"/sbin/nologin"|"/bin/false")
			continue
			;;
	esac
	sync_user "$username"
done < /etc/passwd
EOF
chmod 0755 "$POST_INSTALL_SCRIPT"

mkdir -p "$(dirname "$POST_INSTALL_WRAPPER")"
cat > "$POST_INSTALL_WRAPPER" <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

exec /usr/bin/hyprtheme-default "$@"
EOF
chmod 0755 "$POST_INSTALL_WRAPPER"

echo "完成：已安裝到 /etc/skel，並部署手動同步命令 ${POST_INSTALL_SCRIPT}。"
echo "用法：${POST_INSTALL_SCRIPT} [username]（不帶參數時會同步所有一般使用者）"

