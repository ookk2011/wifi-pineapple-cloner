#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

# targets to build (16)
declare -a TARGET_LIST=(
  # Buffalo
  "WZR450HP2" "WZR600DHP" "WZRHPAG300H" "WZRHPG300NH" "WZRHPG300NH2" "WZRHPG450H"
  
  # D-Link
  "DGL5500A1" "DIR835A1" "dir-869-a1"
  
  # GL.iNet
  "gl-ar300" "gl-ar300m" "gl-ar750" "gl-ar750s"
  
  # TP-Link
  "archer-c7-v2" "archer-c7-v4" "archer-c7-v5"
)

# for build
OPENWRT_PACKAGES="at autossh base-files bash block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iwinfo kmod-ath kmod-ath9k kmod-ath9k-htc kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-lib-crc-itu-t kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-rtl8192cu kmod-scsi-generic kmod-usb-acm kmod-usb-ledtrig-usbport kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-rndis kmod-usb-ohci kmod-usb-serial-pl2303 kmod-usb-storage-extras kmod-usb-uhci kmod-usb-wdm kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgdbm libgmp10 libiconv-full2 libltdl7 libnet-1.2.x libnl200 libustream-mbedtls20150806 libxml2 logd macchanger mtd nano ncat netcat nginx openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps rtl-sdr ssmtp tcpdump-mini uboot-envtools uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear"



# steps
prepare_build () {
  printf "Prepare build\n"
  printf "******************************\n"

  # clean
  rm -rf _tetrafw.* rootfs-tetra tetra-releases rootfs-freeze.tar tetrafw.bin

  # get target firmware
  # this work only with lastest binwalk version!
  wget https://www.wifipineapple.com/downloads/tetra/latest -O tetrafw.bin
  binwalk tetrafw.bin -e 
  binwalk _tetrafw.bin.extracted/sysupgrade-pineapple-tetra/root -e --preserve-symlinks
  mv _tetrafw.bin.extracted/sysupgrade-pineapple-tetra/_root.extracted/squashfs-root/ rootfs-tetra
  rm -rf _tetrafw.* tetrafw.bin

  # copy pineapple files
  chmod +x copier.sh
  ./copier.sh tetra.filelist rootfs-tetra

  # fix files
  chmod +x tetra-fixer.sh
  ./tetra-fixer.sh

  # freeze build
  tar -cf rootfs-freeze.tar rootfs/
  rm -rf rootfs-tetra rootfs

  mkdir tetra-releases
  cd imagebuilder-19.07.2-ar71xx
}

custom_fixs () {
  if [[ "$1" == "WZR450HP2" || "$1" == "WZR600DHP" || "$1" == "WZRHPAG300H" || "$1" == "WZRHPG300NH" || "$1" == "WZRHPG300NH2" || "$1" == "WZRHPG450H" ]]; then
    printf "Fixing LED path\n"
    sed -i 's/wifi-pineapple-nano:blue:system/buffalo:green:status/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/buffalo:green:status/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/buffalo:green:status/' rootfs/etc/uci-defaults/97-pineapple.sh
  fi

  if [[ "$1" == "DGL5500A1" || "$1" == "DIR835A1" || "$1" == "dir-869-a1" ]]; then
    printf "Fixing LED path\n"
    sed -i 's/wifi-pineapple-nano:blue:system/d-link:white:status/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/d-link:white:status/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/d-link:white:status/' rootfs/etc/uci-defaults/97-pineapple.sh
  fi

  if [[ $1 = "gl-ar300" ]]; then
    printf "Fixing LED path\n"
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar300:wlan/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar300:wlan/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar300:wlan/' rootfs/etc/uci-defaults/97-pineapple.sh
  fi

  if [ $1 = "gl-ar300m" ]; then
    printf "Fixing LED path\n"
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar300m:green:system/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar300m:green:system/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar300m:green:system/' rootfs/etc/uci-defaults/97-pineapple.sh
  fi

  if [ $1 = "gl-ar750" ]; then
    printf "Fixing LED path\n"
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar750:white:power/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar750:white:power/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar750:white:power/' rootfs/etc/uci-defaults/97-pineapple.sh
  fi

  if [ $1 = "gl-ar750s" ]; then
    printf "Fixing LED path\n"
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar750s:green:power/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar750s:green:power/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar750s:green:power/' rootfs/etc/uci-defaults/97-pineapple.sh
  fi

  if [[ "$1" == "archer-c7-v2" || "$1" == "archer-c7-v4" || "$1" == "archer-c7-v5" ]]; then
    printf "Fixing LED path\n"
    sed -i 's/wifi-pineapple-nano:blue:system/tp-link:green:wps/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/tp-link:green:wps/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/tp-link:green:wps/' rootfs/etc/uci-defaults/97-pineapple.sh
  fi
}

prepare_rootfs () {
  rm -rf rootfs/
  tar -xf ../rootfs-freeze.tar
}

build () {
  printf "\nBuild\n"
  printf "******************************\n"
  make image PROFILE=$1 PACKAGES="$OPENWRT_PACKAGES" FILES=rootfs/
  cp bin/targets/*/generic/openwrt-*-generic-*-squashfs-sysupgrade.bin ../tetra-releases
}



# implement this shitty logic
install_ubuntu_deps () {
  printf "Install ubuntu deps...\n"
  printf "******************************\n"

  # install deps openwrt make and others
  apt-get install build-essential python2 wget gawk libncurses5-dev libncursesw5-dev zip rename -y

  # install binwalk
  git clone https://github.com/ReFirmLabs/binwalk
  cd binwalk && sudo python3 setup.py install && sudo ./deps.sh

  printf "Install script end!\n"
}

install_openwrt_deps () {
  printf "Install openwrt deps...\n"
  printf "******************************\n"

  # download imagebuilder
  if [ ! -f "imagebuilder-19.07.2-ar71xx.tar.xz" ]; then
    wget https://downloads.openwrt.org/releases/19.07.2/targets/ar71xx/generic/openwrt-imagebuilder-19.07.2-ar71xx-generic.Linux-x86_64.tar.xz -O imagebuilder-19.07.2-ar71xx.tar.xz
  fi

  rm -rf imagebuilder-19.07.2-ar71xx
  tar xJf imagebuilder-19.07.2-ar71xx.tar.xz
  mv openwrt-imagebuilder-19.07.2-ar71xx-generic.Linux-x86_64 imagebuilder-19.07.2-ar71xx

  # fix imagebuilder problems
  cd imagebuilder-19.07.2-ar71xx
  #sed -i 's/downloads.openwrt.org/archive.openwrt.org/' repositories.conf
  wget https://archive.openwrt.org/releases/19.07.7/packages/mips_24kc/base/libubus20191227_2019-12-27-041c9d1c-1_mips_24kc.ipk -O packages/libubus20191227_2019-12-27-041c9d1c-1_mips_24kc.ipk

  printf "Install script end!\n"
}

build_loop () {
  printf "Starting build loop...\n"
  prepare_build

  for target in ${TARGET_LIST[@]}; do
    printf "\nBuild target: $target\n"
    printf "******************************\n"

    prepare_rootfs
    custom_fixs $target
    build $target
  done

  # fix uggly names
  rename "s/openwrt-19.07.2-ar71xx-generic-//" "tetra-releases/*.bin"
  rename "s/squashfs/tetra/" "tetra-releases/*.bin"

  printf "Build loop end!\n"
}

printf "WiFi Pineapple Tetra builder!\n"
printf "************************************** by DSR!\n\n"

if [ "$1" == "openwrt-deps" ]
then
  install_openwrt_deps
elif [ "$1" == "ubuntu-deps" ]
then
  install_ubuntu_deps
elif [ "$1" == "build" ]
then
  build_loop
else
  printf "Valid command:\n"
  printf "openwrt-deps  -> install imagebuilder and configure it\n"
  printf "ubuntu-deps   -> install ubuntu dependencies\n"
  printf "build         -> build all targets in TARGET_LIST\n"
fi
