#!/bin/bash

HOME_DIR="/home/$USER"
LEDE_DIR="$HOME_DIR/lede"

if [ "$(id -u)" -eq 0 ]; then
    echo "请切换到非 root 用户进行编译。"
    exit 1
fi

if [ ! -d "$LEDE_DIR" ]; then
    echo "Cloning lede repository to $LEDE_DIR"
    git clone https://github.com/coolsnowwolf/lede "$LEDE_DIR"
fi

cd "$LEDE_DIR" || exit
./scripts/feeds update -a
./scripts/feeds install -a

echo "请选择你的机型保存开始下一步准备环境!"
echo "输入  make menuconfig  以开始"
