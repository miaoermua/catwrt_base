import os
import difflib

# 设置路径
USER_HOME = os.path.expanduser("~")
CONFIG_FILE = os.path.join(USER_HOME, "lede", ".config")
ORIGINAL_FILE = "d1.config"
DIFF_FILE = "dX-diff.config"

def read_file(file_path):
    with open(file_path, 'r') as file:
        return file.readlines()

def write_file(file_path, lines):
    with open(file_path, 'w') as file:
        file.writelines(lines)

def append_to_file(file_path, lines):
    with open(file_path, 'a') as file:
        file.writelines(lines)

def compare_configs():
    current_config = read_file(CONFIG_FILE)
    original_config = read_file(ORIGINAL_FILE)

    diff = difflib.unified_diff(original_config, current_config, fromfile=ORIGINAL_FILE, tofile=CONFIG_FILE)
    diff_lines = list(diff)

    if diff_lines:
        append_to_file(DIFF_FILE, "\n\n")
        append_to_file(DIFF_FILE, diff_lines)
        print(f"已追加差异到 {DIFF_FILE}")
    else:
        print("没有检测到差异")

def main():
    if not os.path.isfile(ORIGINAL_FILE):
        write_file(ORIGINAL_FILE, read_file(CONFIG_FILE))
        print(f"初始配置文件已保存为 {ORIGINAL_FILE}")

    while True:
        user_input = input("multi-device-diff: 输入 [1] 进行配置比较，输入 [2] 结束：")
        if user_input == '1':
            compare_configs()
        elif user_input == '2':
            print("脚本结束")
            break
        else:
            print("multi-device-diff: 无效输入，请输入 [1] 或 [2]")

if __name__ == "__main__":
    main()
