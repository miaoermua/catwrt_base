#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0m'

USER_HOME="/home/$USER"
TARGET_DIR="$USER_HOME/lede/package"

if [ "$(id -u)" -eq 0 ]; then
    echo -e "${GREEN}请切换到非 root 用户进行编译。${NC}"
    exit 1
fi

REPOS=(
    "https://github.com/destan19/OpenAppFilter"
    "https://github.com/fw876/helloworld"
    "https://github.com/xiaorouji/openwrt-passwall"
    "https://github.com/xiaorouji/openwrt-passwall2"
    "https://github.com/xiaorouji/openwrt-passwall-packages"
    "https://github.com/rufengsuixing/luci-app-adguardhome"
    "https://github.com/linkease/istore"
    "https://github.com/jerrykuku/luci-theme-argon"
    "https://github.com/0x676e67/luci-theme-design"
    "https://github.com/Zxilly/UA2F"
    "https://github.com/rufengsuixing/luci-app-usb3disable"
    "https://github.com/esirplayground/luci-app-LingTiGameAcc"
    "https://github.com/esirplayground/LingTiGameAcc"
    "https://github.com/esirplayground/luci-app-poweroff"
    "https://github.com/messense/openwrt-netbird"
    "https://github.com/sirpdboy/luci-app-eqosplus"
    "https://github.com/sirpdboy/luci-app-autotimeset"
    "https://github.com/sirpdboy/luci-app-lucky"
    "https://github.com/sirpdboy/luci-app-ddns-go"
    "https://github.com/kuoruan/openwrt-v2ray"
    "https://github.com/Erope/openwrt_nezha"
    "https://github.com/selfcan/luci-app-homebox"
)

# Openclash
OPENCLASH_URL="https://github.com/vernesong/OpenClash/archive/refs/heads/master.zip"
OPENCLASH_DIR="$TARGET_DIR/luci-app-openclash"

# WYC-2020 openwrt-packages
WYC_REPO_URL="https://github.com/WYC-2020/openwrt-packages"
WYC_REPO_DIR="$USER_HOME/openwrt-packages"
WYC_PLUGINS=("alist" "luci-app-alist" "ddnsto" "luci-app-ddnsto")

update_or_clone_repo() {
    repo_url=$1
    repo_name=$(basename -s .git "$repo_url")
    repo_dir="$TARGET_DIR/$repo_name"

    echo -e "${GREEN}Processing $repo_name${NC}"

    if [ ! -d "$repo_dir" ]; then
        echo -e "${GREEN}Cloning $repo_name${NC}"
        git clone "$repo_url" "$repo_dir"
    else
        echo -e "${GREEN}Updating $repo_name${NC}"
        cd "$repo_dir" || exit
        git pull
        cd - || exit
    fi
}

update_openclash() {
    echo -e "${GREEN}Processing luci-app-openclash${NC}"
    if [ -d "$OPENCLASH_DIR" ]; then
        echo -e "${GREEN}Removing old luci-app-openclash${NC}"
        rm -rf "$OPENCLASH_DIR"
    fi
    echo -e "${GREEN}Downloading and extracting OpenClash${NC}"
    wget -O /tmp/master.zip "$OPENCLASH_URL"
    unzip /tmp/master.zip -d /tmp
    mv /tmp/OpenClash-master/luci-app-openclash "$TARGET_DIR/"
    rm -rf /tmp/master.zip /tmp/OpenClash-master
}

update_wyc_plugins() {
    echo -e "${GREEN}Processing WYC-2020 openwrt-packages${NC}"

    if [ -d "$WYC_REPO_DIR" ]; then
        echo -e "${GREEN}Updating WYC-2020 openwrt-packages${NC}"
        cd "$WYC_REPO_DIR" || exit
        git pull
    else
        echo -e "${GREEN}Cloning WYC-2020 openwrt-packages${NC}"
        git clone "$WYC_REPO_URL" "$WYC_REPO_DIR"
    fi

    for plugin in "${WYC_PLUGINS[@]}"; do
        plugin_src="$WYC_REPO_DIR/$plugin"
        plugin_dst="$TARGET_DIR/$plugin"
        if [ -d "$plugin_dst" ]; then
            echo -e "${GREEN}Updating $plugin${NC}"
            rm -rf "$plugin_dst"
        fi
        cp -r "$plugin_src" "$plugin_dst"
    done
}

for repo in "${REPOS[@]}"; do
    update_or_clone_repo "$repo"
done

update_openclash
update_wyc_plugins

echo -e "${GREEN}All repositories are up to date.${NC}"
