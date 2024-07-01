#!/bin/bash

USER_HOME="/home/$USER"
TARGET_DIR="$USER_HOME/lede/package"

if [ "$(id -u)" -eq 0 ]; then
    echo "请切换到非 root 用户进行编译。"
    exit 1
fi

FILES=(
    "$TARGET_DIR/base-files/bin/config_generate https://raw.githubusercontent.com/miaoermua/auto_clonecode/main/v23.8/amd64/base-files/bin/config_generate"
    "$TARGET_DIR/lean/default-settings/files/zzz-default-settings https://raw.githubusercontent.com/miaoermua/auto_clonecode/main/lean/default-settings/files/zzz-default-settings"
    "$TARGET_DIR/base-files/etc/catwrt_release https://raw.githubusercontent.com/miaoermua/auto_clonecode/main/v23.8/amd64/base-files/etc/catwrt_release"
    "$TARGET_DIR/base-files/files/etc/banner https://raw.githubusercontent.com/miaoermua/auto_clonecode/main/v23.8/amd64/base-files/etc/banner"
    "$TARGET_DIR/base-files/files/etc/banner.failsafe https://raw.githubusercontent.com/miaoermua/auto_clonecode/main/v23.8/amd64/base-files/etc/banner.failsafe"
)

CATTOOLS_DIR="$TARGET_DIR/base-files/files/usr/bin"
CATTOOLS_URL="https://raw.githubusercontent.com/miaoermua/cattools/main/cattools.sh"
CATTOOLS_PATH="$CATTOOLS_DIR/cattools"

mkdir -p "$CATTOOLS_DIR"

for file_info in "${FILES[@]}"; do
    file_path=$(echo "$file_info" | awk '{print $1}')
    file_url=$(echo "$file_info" | awk '{print $2}')
    echo "Downloading $file_url to $file_path"
    curl -sL "$file_url" -o "$file_path"
done

echo "Downloading $CATTOOLS_URL to $CATTOOLS_PATH"
curl -sL "$CATTOOLS_URL" -o "$CATTOOLS_PATH"


chmod +x "$TARGET_DIR/base-files/bin/config_generate"
chmod +x "$TARGET_DIR/lean/default-settings/files/zzz-default-settings"
chmod +x "$CATTOOLS_PATH"

echo "成功"
