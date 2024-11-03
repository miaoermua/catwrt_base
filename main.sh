#!/bin/bash

display_menu() {
    echo "1. 更新 CatWrt 模板"
    echo "2. 删除已释放的模板"
    echo "3. 退出"
}

update_template() {
    read -p "输入架构和版本 (例如 mt7621/v24.9 或 diy/theme-whu): " arch_version
    arch=$(echo $arch_version | cut -d'/' -f1)
    version=$(echo $arch_version | cut -d'/' -f2)

    # Update files based on the architecture and version
    if [[ -d "/home/catwrt_base/$arch/$version" ]]; then
        cp /home/catwrt_base/$arch/$version/base-files/files/bin/config_generate /home/lede/package/base-files/files/bin/
        cp /home/catwrt_base/$arch/$version/base-files/files/etc/catwrt_release /home/lede/package/base-files/files/etc/
        cp /home/catwrt_base/$arch/$version/base-files/files/etc/banner /home/lede/package/base-files/files/etc/
        cp /home/catwrt_base/$arch/$version/base-files/files/etc/banner.failsafe /home/lede/package/base-files/files/etc/
        cp /home/catwrt_base/$arch/$version/lean/default-settings/files/zzz-default-settings /home/lede/package/lean/default-settings/files/

        # Handle mtwifi for mt7621
        if [[ $arch == "mt7621" ]]; then
            cp /home/catwrt_base/$arch/$version/base-files/files/etc/init.d/mtwifi /home/lede/package/base-files/files/etc/init.d/
            chmod +x /home/lede/package/base-files/files/etc/init.d/mtwifi
        fi

        # Remove mtwifi if switching from mt7621 to other architectures
        if [[ $arch != "mt7621" && -f /home/lede/package/base-files/files/etc/init.d/mtwifi ]]; then
            rm -f /home/lede/package/base-files/files/etc/init.d/mtwifi
            echo "已删除 mtwifi 脚本"
        fi
        
        chmod +x /home/lede/package/lean/default-settings/files/zzz-default-settings
        chmod +x /home/lede/package/base-files/files/bin/config_generate

        # Add cattools to every architecture
        mkdir -p /home/lede/package/base-files/files/usr/bin
        curl -fsSL https://service.miaoer.xyz/cattools/cattools.sh -o /home/lede/package/base-files/files/usr/bin/cattools
        chmod +x /home/lede/package/base-files/files/usr/bin/cattools

        echo "模板更新完成"
    else
        echo "无效的架构或版本"
    fi
}

delete_template() {
    read -p "输入架构和版本 (例如 mt7621/v24.9 或 diy/theme-whu): " arch_version

    # Define paths to delete
    files_to_delete=(
        "/home/lede/package/base-files/files/bin/config_generate"
        "/home/lede/package/base-files/files/etc/catwrt_release"
        "/home/lede/package/base-files/files/etc/banner"
        "/home/lede/package/base-files/files/etc/banner.failsafe"
        "/home/lede/package/lean/default-settings/files/zzz-default-settings"
        "/home/lede/package/base-files/files/usr/bin/cattools"
    )

    # Loop through files and delete if they exist
    for file in "${files_to_delete[@]}"; do
        if [[ -f "$file" ]]; then
            rm -f "$file"
            echo "已删除: $file"
        fi
    done

    # Special handling for mtwifi
    if [[ -f /home/lede/package/base-files/files/etc/init.d/mtwifi ]]; then
        rm -f /home/lede/package/base-files/files/etc/init.d/mtwifi
        echo "已删除 mtwifi 脚本"
    fi

    echo "模板删除完成"
}

while true; do
    display_menu
    read -p "选择操作: " option
    case $option in
        1) update_template ;;
        2) delete_template ;;
        3) exit 0 ;;
        *) echo "无效选项" ;;
    esac
done
