#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

# targets to build (6)
declare -a TARGET_LIST=(
  # Buffalo
  "WZR450HP2" "WZRHPG300NH" "WZRHPG450H"

  # GL.iNet
  "gl-ar150" "gl-ar300" "gl-ar300m"
)

# for build
OPENWRT_PACKAGES="at autossh base-files block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iperf3 iwinfo kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-rtl8192cu kmod-scsi-generic kmod-usb-acm kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-qmi-wwan kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-net-smsc95xx kmod-usb-ohci kmod-usb-storage-extras kmod-usb-uhci kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgmp10 libiconv-full2 libintl libltdl7 libnet-1.2.x libnl200 libreadline8 libustream-mbedtls20150806 libxml2 logd macchanger mt7601u-firmware mtd nano ncat netcat nginx odhcp6c odhcpd-ipv6only openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps python-logging python-openssl python-sqlite3 rtl-sdr ssmtp tcpdump uboot-envtools uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear"

# no sdr, no kmod-usb-net-*, no kmod-rtl8192cu
OPENWRT_PACKAGES_MINI="at autossh base-files block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iperf3 iwinfo kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-scsi-generic kmod-usb-acm kmod-usb-ohci kmod-usb-storage-extras kmod-usb-uhci kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgmp10 libiconv-full2 libintl libltdl7 libnet-1.2.x libnl200 libreadline8 libustream-mbedtls20150806 libxml2 logd macchanger mt7601u-firmware mtd nano ncat netcat nginx odhcp6c odhcpd-ipv6only openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps python-logging python-openssl python-sqlite3 ssmtp tcpdump uboot-envtools uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear"


# steps
prepare_build () {
  printf "Prepare build\n"
  printf "******************************\n"

  # clean
  rm -rf _nanofw.* rootfs-nano nano-releases rootfs-freeze.tar nanofw.bin

  # get target firmware
  # this work only with lastest binwalk version!
  wget https://www.wifipineapple.com/downloads/nano/latest -O nanofw.bin
  binwalk nanofw.bin -e --preserve-symlinks
  mv _nanofw.bin.extracted/squashfs-root/ rootfs-nano
  rm -rf _nanofw.* nanofw.bin

  # copy pineapple files
  chmod +x copier.sh
  ./copier.sh nano.filelist rootfs-nano

  # fix files
  chmod +x nano-fixer.sh
  ./nano-fixer.sh

  # freeze build
  tar -cf rootfs-freeze.tar rootfs/
  rm -rf rootfs-nano rootfs

  mkdir nano-releases
  cd imagebuilder-19.07.2-ar71xx
}

custom_fixs () {
  if [[ "$1" == "WZR450HP2" || "$1" == "WZRHPG300NH" || "$1" == "WZRHPG450H" ]]; then
    printf "Fixing LED path\n"
    sed -i 's/wifi-pineapple-nano:blue:system/buffalo:green:status/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/buffalo:green:status/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/buffalo:green:status/' rootfs/etc/uci-defaults/97-pineapple.sh
  fi

  if [[ $1 = "gl-ar150" ]]; then
    printf "Fixing LED path\n"  
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar150:orange:wlan/' rootfs/sbin/led
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar150:orange:wlan/' rootfs/etc/uci-defaults/92-system.sh
    sed -i 's/wifi-pineapple-nano:blue:system/gl-ar150:orange:wlan/' rootfs/etc/uci-defaults/97-pineapple.sh

    # fix LAN and WAN ports. No more swapped ports on ar150 
    printf "Fix LAN and WAN ports\n"  
    cp fixs/nano/02-network-ar150-fix rootfs/etc/uci-defaults/02-network-ar150-fix
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
}

prepare_rootfs () {
  rm -rf rootfs/
  tar -xf ../rootfs-freeze.tar
}

build () {
  printf "\nBuild\n"
  printf "******************************\n"

  # build
  make image PROFILE="$1" PACKAGES="$2" FILES=rootfs/
  cp bin/targets/*/generic/openwrt-*-generic-*-squashfs-sysupgrade.bin ../nano-releases

  # fix uggly names
  rename "s/openwrt-19.07.2-ar71xx-generic-//" ../nano-releases/*.bin
  #rename "s/squashfs/nano/" ../nano-releases/*.bin
}



# implement this shitty logic
build_loop () {
  printf "Starting build loop...\n"
  prepare_build

  for target in ${TARGET_LIST[@]}; do
    printf "\nBuild target: $target\n"
    printf "******************************\n"

    prepare_rootfs
    custom_fixs $target

    build $target $OPENWRT_PACKAGES
    rename "s/squashfs/nano/" ../nano-releases/*.bin

    build $target $OPENWRT_PACKAGES_MINI
    rename "s/squashfs/nano-mini/" ../nano-releases/*.bin
  done

  printf "Build loop end!\n"
}

printf "WiFi Pineapple Nano builder!\n"
printf "************************************** by DSR!\n\n"
build_loop
