#!/bin/bash

USER_HOME="/home/$USER"

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${GREEN}需要 root 才能使用，但是编译需要非 root 用户${NC}"
    exit 1
fi

if [ ! -d "/home/lede" ]; then
    echo -e "${GREEN}/home 目录下未找到 lede 源码仓库，请确保源码仓库在 /home 目录下，请善用 mv 命令移动源码仓库${NC}"
    ls /home
    exit 1
fi

AUTO_CLONECODE_REPO_URL="https://github.com/miaoermua/catwrt_base"
AUTO_CLONECODE_DIR="/home/catwrt_base"
TARGET_DIR="/home/lede/package"

CATTOOLS_REPO_URL="https://github.com/miaoermua/cattools"
CATTOOLS_DIR="/home/cattools"
CATTOOLS_TARGET_DIR="$TARGET_DIR/base-files/files/usr/bin"

# Update Catwrt Version
VERSION="v24.9"
CATWRT_ARCH="mt7621"
CATWRT_BASE_ARCH="amd64"

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
    "$TARGET_DIR/base-files/files/bin/config_generate $AUTO_CLONECODE_DIR/$VERSION/$CATWRT_BASE_ARCH/base-files/bin/config_generate"
    "$TARGET_DIR/lean/default-settings/files/zzz-default-settings $AUTO_CLONECODE_DIR/lean/default-settings/files/zzz-default-settings"
    "$TARGET_DIR/base-files/files/etc/catwrt_release $AUTO_CLONECODE_DIR/$VERSION/$CATWRT_ARCH/base-files/etc/catwrt_release"
    "$TARGET_DIR/base-files/files/etc/banner $AUTO_CLONECODE_DIR/$VERSION/$CATWRT_ARCH/base-files/etc/banner"
    "$TARGET_DIR/base-files/files/etc/banner.failsafe $AUTO_CLONECODE_DIR/$VERSION/$CATWRT_ARCH/base-files/etc/banner.failsafe"
    "$TARGET_DIR/base-files/files/etc/init.d/mtkwifi $AUTO_CLONECODE_DIR/$VERSION/$CATWRT_ARCH/base-files/etc/init.d/mtkwifi" ## mtkwifi
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
chmod +x "$TARGET_DIR/base-files/files/etc/init.d/mtkwifi" ## mtkwifi

echo "所有文件已下载并替换。"
