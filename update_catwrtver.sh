#!/bin/bash

USER_HOME="/home/$USER"

if [ "$(id -u)" -eq 0 ]; then
    echo "请切换到非 root 用户进行编译。"
    exit 1
fi

AUTO_CLONECODE_REPO_URL="https://github.com/miaoermua/catwrt_base"
AUTO_CLONECODE_DIR="$USER_HOME/catwrt_base"
TARGET_DIR="$USER_HOME/lede/package"

CATTOOLS_REPO_URL="https://github.com/miaoermua/cattools"
CATTOOLS_DIR="$USER_HOME/cattools"
CATTOOLS_TARGET_DIR="$TARGET_DIR/base-files/files/usr/bin"

# Update Catwrt Version
VERSION="v24.9"

# autoclonecode
if [ -d "$AUTO_CLONECODE_DIR" ]; then
    echo "Updating repository $AUTO_CLONECODE_DIR"
    cd "$AUTO_CLONECODE_DIR" && git pull
else
    echo "Cloning repository $AUTO_CLONECODE_REPO_URL to $AUTO_CLONECODE_DIR"
    git clone "$AUTO_CLONECODE_REPO_URL" "$AUTO_CLONECODE_DIR"
fi

# cattools
if [ -d "$CATTOOLS_DIR" ]; then
    echo "Updating repository $CATTOOLS_DIR"
    cd "$CATTOOLS_DIR" && git pull
else
    echo "Cloning repository $CATTOOLS_REPO_URL to $CATTOOLS_DIR"
    git clone "$CATTOOLS_REPO_URL" "$CATTOOLS_DIR"
fi

FILES=(
    "$TARGET_DIR/base-files/files/bin/config_generate $AUTO_CLONECODE_DIR/$VERSION/amd64/base-files/bin/config_generate"
    "$TARGET_DIR/lean/default-settings/files/zzz-default-settings $AUTO_CLONECODE_DIR/lean/default-settings/files/zzz-default-settings"
    "$TARGET_DIR/base-files/files/etc/catwrt_release $AUTO_CLONECODE_DIR/$VERSION/amd64/base-files/etc/catwrt_release"
    "$TARGET_DIR/base-files/files/etc/banner $AUTO_CLONECODE_DIR/$VERSION/amd64/base-files/etc/banner"
    "$TARGET_DIR/base-files/files/etc/banner.failsafe $AUTO_CLONECODE_DIR/$VERSION/amd64/base-files/etc/banner.failsafe"
)

mkdir -p "$CATTOOLS_TARGET_DIR"

for file_info in "${FILES[@]}"; do
    file_path=$(echo "$file_info" | awk '{print $1}')
    src_path=$(echo "$file_info" | awk '{print $2}')
    if ! cmp -s "$file_path" "$src_path"; then
        echo "Replacing $file_path with $src_path"
        cp "$src_path" "$file_path"
    fi
done

CATTOOLS_SRC="$CATTOOLS_DIR/cattools.sh"
CATTOOLS_PATH="$CATTOOLS_TARGET_DIR/cattools"

if [ ! -f "$CATTOOLS_PATH" ] || ! cmp -s "$CATTOOLS_PATH" "$CATTOOLS_SRC"; then
    echo "Replacing $CATTOOLS_PATH with $CATTOOLS_SRC"
    cp "$CATTOOLS_SRC" "$CATTOOLS_PATH"
fi

chmod +x "$TARGET_DIR/base-files/files/bin/config_generate"
chmod +x "$TARGET_DIR/lean/default-settings/files/zzz-default-settings"
chmod +x "$CATTOOLS_PATH"

echo "所有文件已下载并替换。"
