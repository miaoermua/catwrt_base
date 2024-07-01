#!/bin/bash

USER_HOME="/home/$USER"

if [ "$(id -u)" -eq 0 ]; then
    echo "请切换到非 root 用户进行编译。"
    exit 1
fi

REPO_URL="https://github.com/miaoermua/auto_clonecode"
CLONE_DIR="$USER_HOME/auto_clonecode"
TARGET_DIR="$USER_HOME/lede/package"

if [ -d "$CLONE_DIR" ]; then
    echo "Updating repository $CLONE_DIR"
    cd "$CLONE_DIR" && git pull
else
    echo "Cloning repository $REPO_URL to $CLONE_DIR"
    git clone "$REPO_URL" "$CLONE_DIR"
fi

FILES=(
    "$TARGET_DIR/base-files/bin/config_generate $CLONE_DIR/main/v23.8/amd64/base-files/bin/config_generate"
    "$TARGET_DIR/lean/default-settings/files/zzz-default-settings $CLONE_DIR/main/lean/default-settings/files/zzz-default-settings"
    "$TARGET_DIR/base-files/etc/catwrt_release $CLONE_DIR/main/v23.8/amd64/base-files/etc/catwrt_release"
    "$TARGET_DIR/base-files/files/etc/banner $CLONE_DIR/main/v23.8/amd64/base-files/etc/banner"
    "$TARGET_DIR/base-files/files/etc/banner.failsafe $CLONE_DIR/main/v23.8/amd64/base-files/etc/banner.failsafe"
)

CATTOOLS_DIR="$TARGET_DIR/base-files/files/usr/bin"
CATTOOLS_SRC="$CLONE_DIR/main/cattools.sh"
CATTOOLS_PATH="$CATTOOLS_DIR/cattools"

mkdir -p "$CATTOOLS_DIR"

for file_info in "${FILES[@]}"; do
    file_path=$(echo "$file_info" | awk '{print $1}')
    src_path=$(echo "$file_info" | awk '{print $2}')
    if ! cmp -s "$file_path" "$src_path"; then
        echo "Replacing $file_path with $src_path"
        cp "$src_path" "$file_path"
    fi
done

if [ ! -f "$CATTOOLS_PATH" ] || ! cmp -s "$CATTOOLS_PATH" "$CATTOOLS_SRC"; then
    echo "Replacing $CATTOOLS_PATH with $CATTOOLS_SRC"
    cp "$CATTOOLS_SRC" "$CATTOOLS_PATH"
fi

chmod +x "$TARGET_DIR/base-files/bin/config_generate"
chmod +x "$TARGET_DIR/lean/default-settings/files/zzz-default-settings"
chmod +x "$CATTOOLS_PATH"

echo "所有文件已下载并替换。"
