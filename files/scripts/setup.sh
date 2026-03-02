#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/dots-hyprland"

if [[ $EUID -ne 0 ]]; then
	echo "請使用 root 權限執行（blue-build 構建環境通常已是 root）。" >&2
	exit 1
fi

if [[ ! -d "$REPO_ROOT" ]]; then
	echo "來源目錄不存在: $REPO_ROOT" >&2
	exit 1
fi

cd "$REPO_ROOT"

source ./sdata/lib/environment-variables.sh
source ./sdata/lib/functions.sh

# 強制 Fedora 安裝路徑，跳過依賴與 setup，僅執行主題檔案安裝
OS_DISTRO_ID="fedora"
OS_DISTRO_ID_LIKE="fedora"
OS_GROUP_ID="fedora"
INSTALL_VIA_NIX=false

SKIP_ALLDEPS=false
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

EXPERIMENTAL_FILES_SCRIPT=false
INSTALL_FIRSTRUN=false

# 系統級目標目錄
XDG_CONFIG_HOME="/usr/etc"
XDG_DATA_HOME="/usr/share"
XDG_BIN_HOME="/usr/bin"
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

echo "完成：已按 setup 邏輯安裝 Fedora 主題配置。"

