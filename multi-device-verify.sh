#!/bin/bash

TARGET_DIR="/home/lede/bin/targets/ramips/mt7621/packages"
PACKAGES_FILE="$TARGET_DIR/Packages"
CONFIG_FILE="/home/lede/.config"

get_dir_hash() {
  find "$TARGET_DIR" -type f -exec sha256sum {} \; | sha256sum | awk '{print $1}'
}

get_config_hash() {
  sha256sum "$CONFIG_FILE" | awk '{print $1}'
}

get_kernel_version() {
  grep "Depends: kernel" "$PACKAGES_FILE" | awk -F '[()]' '{if (!seen[$2]++) print $2}'
}

initial_dir_hash=$(get_dir_hash)
initial_kernel_version=$(get_kernel_version)

echo
echo "初始目录 hash 值: $initial_dir_hash"
echo "初始 kernel 版本: $initial_kernel_version"
initial_config_hash=$(get_config_hash)
echo "初始 .config 文件 hash 值: $initial_config_hash"
echo

while true; do
  read -p "multi-device-verify: 按 [1] 继续检查，按 [2] 退出: " user_input
  if [ "$user_input" == "2" ]; then
    echo "multi-device-verify: 脚本结束!"
    exit 0
  elif [ "$user_input" == "1" ]; then
    current_config_hash=$(get_config_hash)
    current_dir_hash=$(get_dir_hash)
    current_kernel_version=$(get_kernel_version)

    if [ "$initial_dir_hash" != "$current_dir_hash" ] || [ "$initial_kernel_version" != "$current_kernel_version" ]; then
      echo "multi-device-verify: 目录 hash 值或 kernel 版本发生变化，脚本结束"
      exit 1
    else
      echo "multi-device-verify: 目录 hash 值和 kernel 版本一致，继续前进吧!"
    fi

    if [ "$initial_config_hash" != "$current_config_hash" ]; then
      echo "multi-device-verify: .config 已修改，继续检查"
      echo
      initial_config_hash=$current_config_hash
    else
      echo "multi-device-verify: .config 文件未变化"
    fi
    echo
  else
    echo "无效输入，请输入 [1] 或 [2]。"
  fi
done
