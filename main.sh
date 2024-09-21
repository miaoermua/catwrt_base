#!/bin/bash

# 颜色设置
GREEN='\033[0;32m'
NC='\033[0m'

USER_HOME="/home/$USER"
LEDE_DIR="/home/lede"
CATWRT_BASE_DIR="/home/catwrt_base"
TARGET_DIR="/home/lede/package"
CATTOOLS_TARGET_DIR="$TARGET_DIR/base-files/files/usr/bin"
MTKWIFI_FILE="$TARGET_DIR/base-files/files/etc/init.d/mtkwifi"

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${GREEN}需要 root 才能使用，但是编译需要非 root 用户${NC}"
    exit 1
fi

if [ ! -d "$LEDE_DIR" ]; then
    echo -e "${GREEN}/home 目录下未找到 lede 源码仓库，请确保源码仓库在 /home 目录下${NC}"
    exit 1
fi

show_menu() {
    echo "请选择一个选项："
    echo "1. 删除已释放的文件"
    echo "2. 更新 LEDE 源码"
    echo "3. 更新 CatWrt 模板"
    echo "0. 退出"
    read -p "请输入选项: " choice
}

delete_released_files() {
    echo "删除已释放的文件以确保 lede 源码可以更新"
    FILES_TO_REMOVE=(
        "$TARGET_DIR/base-files/files/bin/config_generate"
        "$TARGET_DIR/lean/default-settings/files/zzz-default-settings"
        "$TARGET_DIR/base-files/files/etc/catwrt_release"
        "$TARGET_DIR/base-files/files/etc/banner"
        "$TARGET_DIR/base-files/files/etc/banner.failsafe"
        "$MTKWIFI_FILE"
    )

    for file in "${FILES_TO_REMOVE[@]}"; do
        if [ -f "$file" ]; then
            echo "删除文件: $file"
            rm -f "$file"
        fi
    done
    echo "已删除修改过的文件，您可以继续执行 git pull。"
}

update_lede() {
    if [ -d "$LEDE_DIR" ]; then
        echo "更新 LEDE 源码..."
        cd "$LEDE_DIR" && git pull
    else
        echo "未找到 lede 代码，克隆 lede 仓库到 $LEDE_DIR"
        git clone https://github.com/coolsnowwolf/lede "$LEDE_DIR"
    fi
}

select_version() {
    local arch_dir="$1"
    local versions=($(ls "$arch_dir"))

    if [ ${#versions[@]} -eq 1 ]; then
        echo "${GREEN}检测到唯一版本：${versions[0]}${NC}"
        echo "${versions[0]}"
    else
        echo "请选择版本："
        select version in "${versions[@]}"; do
            if [ -n "$version" ]; then
                echo "$version"
                return
            else
                echo "无效选择，请重试。"
            fi
        done
    fi
}

update_catwrt_template() {
    read -p "请输入架构类型 (例如 mt798x, mt7621, amd64 或 diy): " CATWRT_ARCH

    if [ "$CATWRT_ARCH" == "diy" ]; then
        read -p "请输入自定义文件夹路径 (例如 /diy/theme-whu): " DIY_DIR
        DIY_DIR=$(echo "$DIY_DIR" | sed 's:/*$::')
        BASE_DIR="$DIY_DIR/base-files"
        LEAN_DIR="$DIY_DIR/lean/default-settings/files"

        echo "检查路径: $BASE_DIR 和 $LEAN_DIR"

        if [ ! -d "$BASE_DIR" ]; then
            echo "错误：目录 $BASE_DIR 不存在。"
            exit 1
        fi

        if [ ! -d "$LEAN_DIR" ]; then
            echo "错误：目录 $LEAN_DIR 不存在。"
            exit 1
        fi
    else
        ARCH_DIR="$CATWRT_BASE_DIR/$CATWRT_ARCH"

        if [ ! -d "$ARCH_DIR" ]; then
            echo "错误：$ARCH_DIR 文件夹不存在，请确保 CatWrt 源码中有此架构目录。"
            exit 1
        fi

        VERSION=$(select_version "$ARCH_DIR")
        BASE_DIR="$ARCH_DIR/$VERSION/base-files"
        LEAN_DIR="$ARCH_DIR/$VERSION/lean/default-settings/files"
    fi

    echo "更新 CatWrt 模板文件..."

    FILES=(
        "$TARGET_DIR/base-files/files/bin/config_generate $BASE_DIR/bin/config_generate"
        "$TARGET_DIR/base-files/files/etc/catwrt_release $BASE_DIR/etc/catwrt_release"
        "$TARGET_DIR/base-files/files/etc/banner $BASE_DIR/etc/banner"
        "$TARGET_DIR/base-files/files/etc/banner.failsafe $BASE_DIR/etc/banner.failsafe"
        "$TARGET_DIR/lean/default-settings/files/zzz-default-settings $LEAN_DIR/zzz-default-settings"
    )

    if [ "$CATWRT_ARCH" == "mt7621" ]; then
        FILES+=("$MTKWIFI_FILE $BASE_DIR/etc/init.d/mtkwifi")
    else
        if [ -f "$MTKWIFI_FILE" ]; then
            echo "检测到非 mt7621 架构，删除 $MTKWIFI_FILE"
            rm -f "$MTKWIFI_FILE"
        fi
    fi

    for file_info in "${FILES[@]}"; do
        file_path=$(echo "$file_info" | awk '{print $1}')
        src_path=$(echo "$file_info" | awk '{print $2}')
        if [ -f "$src_path" ]; then
            echo "替换 $file_path 为 $src_path"
            cp "$src_path" "$file_path"
        else
            echo "未找到文件 $src_path，跳过替换。"
        fi
    done

    chmod +x "$TARGET_DIR/base-files/files/bin/config_generate"
    chmod +x "$TARGET_DIR/lean/default-settings/files/zzz-default-settings"
    if [ "$CATWRT_ARCH" == "mt7621" ]; then
        chmod +x "$MTKWIFI_FILE"
    fi
    echo "CatWrt 模板文件已更新。"
}

while true; do
    show_menu
    case $choice in
        1) delete_released_files ;;
        2) update_lede ;;
        3) update_catwrt_template ;;
        0) echo "退出脚本"; exit 0 ;;
        *) echo "无效选项，请重新输入。" ;;
    esac
done
