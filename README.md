
**更新插件库**
```bash
curl https://raw.githubusercontent.com/miaoermua/auto_clonecode/main/pull.sh | bash
```

**刷版本号**
```bash
curl https://raw.githubusercontent.com/miaoermua/auto_clonecode/main/update_catwrtver.sh | bash
```

---

用于首次部署编译环境

## 准备环境

```bash
sudo bash -c 'bash <(curl -s https://build-scripts.immortalwrt.org/init_build_environment.sh)'
```

```bash
sudo apt update -y
sudo apt full-upgrade -y
sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev \
libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev \
libssl-dev libtool lrzsz mkisofs msmtp ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 \
python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo \
uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
```

[coolsnowwolf/lede: Lean's LEDE source](https://github.com/coolsnowwolf/lede)
[immortalwrt/immortalwrt: An opensource OpenWrt variant for mainland China users.](https://github.com/immortalwrt/immortalwrt)
