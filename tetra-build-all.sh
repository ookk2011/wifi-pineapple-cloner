#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

# targets to build
# targets: 11
TARGET_LIST_GENERIC=(
  # Buffalo
  "WZR600DHP" "WZRHPAG300H" "WZRHPG300NH2"
  
  # D-Link
  "DGL5500A1" "DIR835A1" "dir-869-a1"
  
  # GL.iNet
  "gl-ar750" "gl-ar750s"
  
  # TP-Link
  "archer-c7-v2" "archer-c7-v4" "archer-c7-v5"
)

# targets: 4
TARGET_LIST_NAND=(
  # Zyxel
  "NBG6716"

  # NETGEAR
  "R6100" "WNDR3700V4" "WNDR4300V1"
)

# for build
# no python-logging, no python-openssl, no python-sqlite3
OPENWRT_PACKAGES="at autossh base-files bash block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iwinfo kmod-ath kmod-ath9k kmod-ath9k-htc kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-lib-crc-itu-t kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-rtl8192cu kmod-scsi-generic kmod-usb-acm kmod-usb-ledtrig-usbport kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-rndis kmod-usb-ohci kmod-usb-serial-pl2303 kmod-usb-storage-extras kmod-usb-uhci kmod-usb-wdm kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgdbm libgmp10 libiconv-full2 libltdl7 libnet-1.2.x libnl200 libustream-mbedtls20150806 libxml2 logd macchanger mtd nano ncat netcat nginx openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps rtl-sdr ssmtp tcpdump-mini uboot-envtools uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear"

# no sdr, no kmod-usb-net-*, no kmod-rtl8192cu
OPENWRT_PACKAGES_MINI="at autossh base-files bash block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iwinfo kmod-ath kmod-ath9k kmod-ath9k-htc kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-lib-crc-itu-t kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-scsi-generic kmod-usb-acm kmod-usb-ledtrig-usbport kmod-usb-ohci kmod-usb-serial-pl2303 kmod-usb-storage-extras kmod-usb-uhci kmod-usb-wdm kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgdbm libgmp10 libiconv-full2 libltdl7 libnet-1.2.x libnl200 libustream-mbedtls20150806 libxml2 logd macchanger mtd nano ncat netcat nginx openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps ssmtp tcpdump-mini uboot-envtools uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear"

OPENWRT_VERSION="19.07.2"
CWD="$(pwd)"


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
}

custom_fixs () {
  if [[ "$1" == "WZR600DHP" || "$1" == "WZRHPAG300H" || "$1" == "WZRHPG300NH2" ]]; then
    printf "Fixing LED path\n"
    # check /etc/diag.sh for this data!
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

  if [ $1 = "NBG6716" ]; then
    printf "Fixing LED path\n"
    sed -i 's/wifi-pineapple-nano:blue:system/nbg6716:white:power/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/nbg6716:white:power/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/nbg6716:white:power/' rootfs/etc/uci-defaults/97-pineapple.sh
  fi

  if [[ "$1" == "R6100" || "$1" == "WNDR3700V4" || "$1" == "WNDR4300V1" ]]; then
    printf "Fixing LED path\n"
    sed -i 's/wifi-pineapple-nano:blue:system/netgear:green:power/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/netgear:green:power/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/netgear:green:power/' rootfs/etc/uci-defaults/97-pineapple.sh
  fi
}

prepare_rootfs () {
  rm -rf rootfs/
  tar -xf ../rootfs-freeze.tar
}

build () {
  printf "\nBuild\n"
  printf "******************************\n"

  # clean
  #make clean
  rm -rf tmp/ build_dir/target-mips_24kc_musl/root-ar71xx bin/targets/ar71xx/generic bin/targets/ar71xx/nand

  # build
  make image PROFILE="$1" PACKAGES="$2" FILES=rootfs/

  # fix uggly names and copy
  rename "s/openwrt-$OPENWRT_VERSION-ar71xx-generic-//" bin/targets/*/generic/*-squashfs-sysupgrade.bin
  rename "s/openwrt-$OPENWRT_VERSION-ar71xx-nand-//" bin/targets/*/nand/*-squashfs-sysupgrade.tar
  cp bin/targets/*/generic/*-squashfs-sysupgrade.bin ../tetra-releases
  cp bin/targets/*/nand/*-squashfs-sysupgrade.tar ../tetra-releases
}



# implement this shitty logic
build_loop () {
  printf "Starting build loop...\n"
  prepare_build

  cd "$CWD/imagebuilder-$OPENWRT_VERSION-ar71xx"
  for target in ${TARGET_LIST_GENERIC[@]}; do
    printf "\nBuild target: $target\n"
    printf "******************************\n"

    prepare_rootfs
    custom_fixs "$target"

    build "$target" "$OPENWRT_PACKAGES"
    rename "s/squashfs/tetra/" ../tetra-releases/*.bin

    build "$target" "$OPENWRT_PACKAGES_MINI"
    rename "s/squashfs/tetra-mini/" ../tetra-releases/*.bin
  done

  cd "$CWD/imagebuilder-$OPENWRT_VERSION-ar71xx-nand"
  for target in ${TARGET_LIST_NAND[@]}; do
    printf "\nBuild target: $target\n"
    printf "******************************\n"

    prepare_rootfs
    custom_fixs "$target"

    build "$target" "$OPENWRT_PACKAGES"
    rename "s/squashfs/tetra/" ../tetra-releases/*.tar

    build "$target" "$OPENWRT_PACKAGES_MINI"
    rename "s/squashfs/tetra-mini/" ../tetra-releases/*.tar
  done

  printf "Build loop end!\n"
}

printf "WiFi Pineapple Tetra builder!\n"
printf "************************************** by DSR!\n\n"
build_loop
