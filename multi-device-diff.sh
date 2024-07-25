#!/bin/bash

USER_HOME="/home/$USER"

if [ "$(id -u)" -eq 0 ]; then
    echo "请切换到非 root 用户进行编译。"
    exit 1
fi

CONFIG_FILE="$USER_HOME/lede/.config"
ORIGINAL_FILE="d1.config"
DIFF_FILE="dX-diff.config"

# 初始创建原始配置文件
if [ ! -f "$ORIGINAL_FILE" ]; then
    cp "$CONFIG_FILE" "$ORIGINAL_FILE"
    echo "初始配置文件已保存为 $ORIGINAL_FILE"
fi

compare_configs() {
    # 临时文件用于存储当前配置文件
    TEMP_FILE=$(mktemp)
    cp "$CONFIG_FILE" "$TEMP_FILE"

    # 比较并提取差异
    diff -u "$ORIGINAL_FILE" "$TEMP_FILE" > diff_output

    # 过滤出有意义的差异（去除 diff 标记行）
    grep '^\(+\|-\)' diff_output | grep -v '^\(\+\+\+\|---\)' > filtered_diff

    # 追加到差异文件
    if [ -s filtered_diff ]; then
        echo -e "\n\n" >> "$DIFF_FILE"
        cat filtered_diff >> "$DIFF_FILE"
        echo "已追加差异到 $DIFF_FILE"
    else
        echo "没有检测到差异"
    fi

    # 清理临时文件
    rm "$TEMP_FILE" diff_output filtered_diff
}

# 主循环
while true; do
  echo -n "[INFO] 输入 [1] 进行配置比较，输入 [2]结束脚本："
  read -r input
  case $input in
    1)
      compare_configs
      ;;
    2)
      echo "脚本结束"
      break
      ;;
    *)
      echo "无效输入，请输入 [1] 或 [2]"
      ;;
  esac
done
