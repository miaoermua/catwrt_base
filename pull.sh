#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0m'

USER_HOME="/home"
TARGET_DIR="/home/lede/package"

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${GREEN}需要 root 才能使用，但是编译需要非 root 用户${NC}"
    exit 1
fi

if [ ! -d "/home/lede" ]; then
    echo -e "${GREEN}/home 目录下未找到 lede 源码仓库，请确保源码仓库在 /home 目录下，请善用 mv 命令移动源码仓库${NC}"
    ls /home
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
    "https://github.com/0x676e67/luci-theme-design"
    "https://github.com/Zxilly/UA2F"               ## will use v4.5.0 tag
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
    "https://github.com/selfcan/luci-app-homebox"  ## LUCI NOT WORK!
    "https://github.com/sbwml/luci-app-alist"      ## will use v3.40.0 tag
    "https://github.com/ilxp/luci-app-ikoolproxy"
    "https://github.com/jimlee2002/openwrt-minieap-gdufs"
    "https://github.com/jimlee2048/luci-proto-minieap"
    "https://github.com/ysc3839/openwrt-minieap"
    "https://github.com/BoringCat/luci-app-mentohust"
    "https://github.com/BoringCat/luci-app-minieap"
    "https://github.com/FUjr/luci-theme-asus"
    "https://github.com/SunBK201/UA3F"
    "https://github.com/yuhanjin/feed-netkeeper"
    "https://github.com/EOYOHOO/rkp-ipid"
    "https://github.com/EasyTier/luci-app-easytier"
    "https://github.com/MikeWang000000/FakeHTTP"
)

# Openclash
OPENCLASH_URL="https://github.com/vernesong/OpenClash/archive/refs/heads/master.zip"
OPENCLASH_DIR="$TARGET_DIR/luci-app-openclash"

# WYC-2020 openwrt-packages
WYC_REPO_URL="https://github.com/WYC-2020/openwrt-packages"
WYC_REPO_DIR="$USER_HOME/openwrt-packages"
WYC_PLUGINS=("ddnsto" "luci-app-ddnsto")

# download kami background
BACKGROUND_IMAGE_URL="https://cdn.miaoer.net/images/bg/kami/background.png"
BACKGROUND_IMAGE_PATH="$TARGET_DIR/luci-theme-argon/htdocs/luci-static/argon/background"

update_or_clone_repo() {
    repo_url=$1
    repo_name=$(basename -s .git "$repo_url")
    repo_dir="$TARGET_DIR/$repo_name"

    if [ ! -d "$repo_dir" ]; then
        echo -e "${GREEN}Cloning $repo_name${NC}"

        case "$repo_name" in
            UA2F)
                git clone -b v4.5.0 "$repo_url" "$repo_dir"
                ;;
            luci-app-alist)
                git clone -b v3.40.0 "$repo_url" "$repo_dir"
                ;;
            *)
                git clone "$repo_url" "$repo_dir"
                ;;
        esac
    else
        echo -e "${GREEN}Updating $repo_name${NC}"
        cd "$repo_dir" || exit

        case "$repo_name" in
            UA2F)
                git fetch --tags
                git checkout v4.5.0
                ;;
            luci-app-alist)
                git fetch --tags
                git checkout v3.40.0
                ;;
            *)
                git pull
                ;;
        esac

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

update_bitsrunlogin_go() {
    echo -e "${GREEN}Processing immortalwrt luci & packages for bitsrunlogin-go${NC}"

    TEMP_DIR="/tmp/immortalwrt_bitsrunlogin"

    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi

    echo -e "${GREEN}Cloning immortalwrt/luci into $TEMP_DIR/luci${NC}"
    git clone --depth=1 https://github.com/immortalwrt/luci.git  "$TEMP_DIR/luci"

    echo -e "${GREEN}Cloning immortalwrt/packages into $TEMP_DIR/packages${NC}"
    git clone --depth=1 https://github.com/immortalwrt/packages.git  "$TEMP_DIR/packages"

    LUCI_SRC="$TEMP_DIR/luci/applications/luci-app-bitsrunlogin-go"
    LUCI_DST="$TARGET_DIR/luci-app-bitsrunlogin-go"
    if [ -d "$LUCI_DST" ]; then
        echo -e "${GREEN}Removing old luci-app-bitsrunlogin-go${NC}"
        rm -rf "$LUCI_DST"
    fi
    cp -r "$LUCI_SRC" "$LUCI_DST"

    PKG_SRC="$TEMP_DIR/packages/net/bitsrunlogin-go"
    PKG_DST="$TARGET_DIR/bitsrunlogin-go"
    if [ -d "$PKG_DST" ]; then
        echo -e "${GREEN}Removing old bitsrunlogin-go${NC}"
        rm -rf "$PKG_DST"
    fi
    cp -r "$PKG_SRC" "$PKG_DST"

    rm -rf "$TEMP_DIR"
}

update_luci_theme_argon() {
    repo_url="https://github.com/jerrykuku/luci-theme-argon"
    repo_name=$(basename -s .git "$repo_url")
    repo_dir="$TARGET_DIR/$repo_name"

    echo -e "${GREEN}Processing $repo_name${NC}"

    if [ ! -d "$repo_dir" ]; then
        echo -e "${GREEN}Cloning $repo_name (branch 18.06)${NC}"
        git clone -b 18.06 "$repo_url" "$repo_dir"
    else
        echo -e "${GREEN}Updating $repo_name${NC}"
        cd "$repo_dir" || exit
        git pull origin 18.06
        rm -rf ../feeds/luci/theme/luci-theme-argon
        cd - || exit
    fi

    if [ ! -f "$BACKGROUND_IMAGE_PATH/background.png" ]; then
        echo -e "${GREEN}Downloading background image${NC}"
        mkdir -p "$BACKGROUND_IMAGE_PATH"
        wget -O "$BACKGROUND_IMAGE_PATH/background.png" "$BACKGROUND_IMAGE_URL"
    else
        echo -e "${GREEN}Background image already exists, skipping download${NC}"
    fi
}

for repo in "${REPOS[@]}"; do
    update_or_clone_repo "$repo"
done

update_openclash
update_wyc_plugins
update_bitsrunlogin_go
update_luci_theme_argon

echo -e "${GREEN}All repositories are up to date.${NC}"
