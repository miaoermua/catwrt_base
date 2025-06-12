# catwrt_base

> 请不要继续 fork，近日开发工作讲优化结构。

CatWrt_Base 是基于 [Lean's LEDE](https://github.com/coolsnowwolf/lede) 修改的发行版基础资源仓库，将二次编辑好的内容上传到本仓库再通过自动化脚本安装到对应位置实现预装到系统中。

相比 [miaoermua/CatWrt](https://github.com/miaoermua/CatWrt) 的二进制软件源仓库，这里就差不多是源代码了，不过都是一些修改向的脚本，本仓库不会存储二进制&闭源代码，也不会集成闭源代码到 CatWrt 中!

实现编译半自动化，版本管理，文件统一；脚本需要 root 运行，编译只能普通用户；资源文件和 LEDE 源码需要存储在 `/home` 才能正常食用。

[![Stars](https://m3-markdown-badges.vercel.app/stars/3/3/miaoermua/catwrt_base)](https://github.com/miaoermua/catwrt_base)
[![Issues](https://m3-markdown-badges.vercel.app/issues/1/2/miaoermua/catwrt_base)](https://github.com/miaoermua/catwrt_base/issues)
[![Support](https://ziadoua.github.io/m3-Markdown-Badges/badges/Sponsor/sponsor1.svg)](https://www.miaoer.net/sponsor)
[![COPYING](https://ziadoua.github.io/m3-Markdown-Badges/badges/LicenceGPLv2/licencegplv23.svg)](https://github.com/miaoermua/catwrt_base/blob/main/COPYING)

**更新插件库**
```bash
sudo curl https://raw.githubusercontent.com/miaoermua/catwrt_base/main/pull.sh | sudo bash
```

**刷版本号** （更新 CatWrt 关键文件）
```bash
sudo curl https://raw.githubusercontent.com/miaoermua/catwrt_base/main/mian.sh | sudo bash
```

版本描述：
CatWrt 的 Arch & Version 对应目录中的 `chip & architecture / version` 如 `amd64/v24.9`

---

## 准备环境

用于首次部署编译环境

```bash
sudo bash -c 'bash <(curl -s https://build-scripts.immortalwrt.org/init_build_environment.sh)'
```

```bash
sudo apt update -y
sudo apt full-upgrade -y
sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
```

## 更新源码

更新 LEDE 源码和执行 feeds 脚本更新源码仓库的插件

> 请不要给 LEDE 使用任何 sudo 或 root 用户污染源码权限。
>
> ```bash
> sudo chown -R miaoer:miaoer /home/miaoer/lede
> ```

```bash
cd ~/lede
git pull
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
make download -j8
```

## 编译

```bash
make menuconfig
make V=s -j$(nproc)
```

[coolsnowwolf/lede: Lean's LEDE source](https://github.com/coolsnowwolf/lede)

[immortalwrt/immortalwrt: An opensource OpenWrt variant for mainland China users.](https://github.com/immortalwrt/immortalwrt)


## 解决问题

[Alist Golang](https://github.com/sbwml/packages_lang_golang)

[Easymesh - mt7621](https://github.com/coolsnowwolf/routing/pull/7)

[MosDNS - mt7621](https://github.com/coolsnowwolf/lede/issues/12117)

---

CatWrt base 和 LEDE 库冲突，保留 LEDE 源码更新放弃 CatWrt 修改，重新执行 main.sh 释放文件。

```logs
hint: You have divergent branches and need to specify how to reconcile them.
hint: You can do so by running one of the following commands sometime before
hint: your next pull:
hint: 
hint:   git config pull.rebase false  # merge (the default strategy)
hint:   git config pull.rebase true   # rebase
hint:   git config pull.ff only       # fast-forward only
hint: 
hint: You can replace "git config" with "git config --global" to set a default
hint: preference for all repositories. You can also pass --rebase, --no-rebase,
hint: or --ff-only on the command line to override the configured default per
hint: invocation.
miaoer@BuildCatWrt:/home/lede$ git fetch origin 
remote: Enumerating objects: 680, done.
remote: Counting objects: 100% (365/365), done.
remote: Compressing objects: 100% (70/70), done.
remote: Total 680 (delta 315), reused 298 (delta 294), pack-reused 315 (from 2)
Receiving objects: 100% (680/680), 322.63 KiB | 3.19 MiB/s, done.
Resolving deltas: 100% (341/341), completed with 119 local objects.
From https://github.com/coolsnowwolf/lede
   0146ee196..433382b8f  master     -> origin/master
miaoer@BuildCatWrt:/home/lede$ git reset --hard origin
HEAD is now at 433382b8f package: add kmod-r8127 ethernet driver
miaoer@BuildCatWrt:/home/lede$ git pull
Already up to date.
```

遇到 naive 编译错误，安装一下额外依赖

```bash
sudo apt install clang generate-ninja
rm -rf build_dir/hostpkg/gn-*/
```

## 协议

CatWrt 和源码你可以自由使用 (GPL2.0) 任何责任需要自行承担，二次发版需要标注来源不得以影响 CatWrt 正式发版，在二次修改发布前需要了解 CatWrt 开发事项应避免关键服务后端 API 和二次开发版本冲突。
