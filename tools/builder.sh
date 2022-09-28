#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

FLAVOR="$1"
IMAGEBUILDER_FOLDER="$2"
PROFILE="$3"
declare -a FLAVOR_TYPES=("nano" "tetra" "universal")
if [[ ! -d "$IMAGEBUILDER_FOLDER" || "$PROFILE" == "" ]] || ! grep -q "$FLAVOR" <<< "${FLAVOR_TYPES[*]}"; then
    echo "Run with \"builder.sh [FLAVOR] [IMAGEBUILDER_FOLDER] [PROFILE]\""
    echo "    FLAVOR              -> must be one of these values: nano, tetra, universal"
    echo "    IMAGEBUILDER_FOLDER -> path to openwrt imagebuilder"
    echo "    PROFILE             -> profile for use in imagebuilder build"

    exit 1
fi

# for build
# no rtl-sdr, no kmod-usb-net-*, no kmod-rtl8192cu, no kmod-usb-acm
PACKAGES_NANO="iw at autossh base-files block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iperf3 iwinfo kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-scsi-generic kmod-usb-ohci kmod-usb-storage-extras kmod-usb-uhci kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgmp10 libiconv-full2 libintl libltdl7 libnet-1.2.x libnl200 libreadline8 libustream-mbedtls20150806 libxml2 logd macchanger mtd nano ncat netcat nginx openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps python-logging python-openssl python-sqlite3 ssmtp tcpdump-mini uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear -swconfig -odhcpd-ipv6only -odhcp6c"

# no rtl-sdr, no kmod-usb-net-*, no kmod-usb-serial-*, no kmod-rtl8192cu, no kmod-usb-acm, no kmod-usb-wdm, no kmod-lib-crc-itu-t
PACKAGES_TETRA="iw at autossh base-files bash block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iwinfo kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-scsi-generic kmod-usb-ohci kmod-usb-storage-extras kmod-usb-uhci kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgdbm libgmp10 libiconv-full2 libltdl7 libnet-1.2.x libnl200 libustream-mbedtls20150806 libxml2 logd macchanger mtd nano ncat netcat nginx openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps python-logging python-openssl python-sqlite3 ssmtp tcpdump-mini uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear -swconfig -odhcp6c -odhcpd-ipv6only"

# no rtl-sdr, no kmod-usb-net-*, no kmod-usb-serial-*, no kmod-rtl8192cu, no kmod-usb-acm, no kmod-usb-wdm, no kmod-lib-crc-itu-t, no python-*
PACKAGES_UNIVERSAL="iw at autossh base-files bash block-mount ca-certificates chat dnsmasq e2fsprogs ethtool fdisk firewall hostapd-utils ip6tables iwinfo kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-scsi-generic kmod-usb-ohci kmod-usb-storage-extras kmod-usb-uhci kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgdbm libgmp10 libiconv-full2 libltdl7 libnet-1.2.x libnl200 libustream-mbedtls20150806 libxml2 logd macchanger mtd nano ncat netcat nginx openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps ssmtp tcpdump-mini uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear -swconfig -odhcp6c -odhcpd-ipv6only"

TOOL_FOLDER="$(realpath $(dirname $0))/../tools"
BUILD_FOLDER="$TOOL_FOLDER/../build"



# steps
prepare_build () {
    printf "Prepare build\n"
    printf "******************************\n"

      # clean
    rm -rf _basefw.* basefw.bin
    rm -rf "$BUILD_FOLDER"
    mkdir -p "$BUILD_FOLDER/release"

    # get target firmware
    # this work only with lastest binwalk version!
    if [[ "$FLAVOR" == "tetra" || "$FLAVOR" == "universal" ]]; then
        wget https://www.wifipineapple.com/downloads/tetra/latest -O basefw.bin
        binwalk basefw.bin -e 
        binwalk _basefw.bin.extracted/sysupgrade-pineapple-tetra/root -e --preserve-symlinks
        mv _basefw.bin.extracted/sysupgrade-pineapple-tetra/_root.extracted/squashfs-root/ "$BUILD_FOLDER/rootfs-base"
    else
        wget https://www.wifipineapple.com/downloads/nano/latest -O basefw.bin
        binwalk basefw.bin -e --preserve-symlinks
        mv _basefw.bin.extracted/squashfs-root/ "$BUILD_FOLDER/rootfs-base"
    fi

    rm -rf _basefw.* basefw.bin

    # copy pineapple files
    #sudo chmod +x "$TOOL_FOLDER/*.sh"
    "$TOOL_FOLDER/copier.sh" "$TOOL_FOLDER/../lists/$FLAVOR.filelist" "$BUILD_FOLDER/rootfs-base" "$BUILD_FOLDER/rootfs"
    "$TOOL_FOLDER/fs-patcher.sh" "$BUILD_FOLDER/rootfs" "$FLAVOR"

    # freeze build
    #tar -cf rootfs-freeze.tar "$BUILD_FOLDER/rootfs"
    #rm -rf "$BUILD_FOLDER/rootfs-base" "$BUILD_FOLDER/rootfs"
    rm -rf "$BUILD_FOLDER/rootfs-base"
}

build () {
    printf "\nBuild\n"
    printf "******************************\n"

    # clean
    #make clean
    rm -rf "$IMAGEBUILDER_FOLDER/tmp/"
    rm -rf "$IMAGEBUILDER_FOLDER/build_dir/target-*/root*"
    rm -rf "$IMAGEBUILDER_FOLDER/build_dir/target-*/json_*"
    rm -rf "$IMAGEBUILDER_FOLDER/bin/targets/*"

    # set selected packages
    selected_packages="$PACKAGES_UNIVERSAL"
    if [[ "$FLAVOR" == "nano" ]];
    then
        selected_packages="$PACKAGES_NANO"
    elif [[ "$FLAVOR" == "tetra" ]];
    then
        selected_packages="$PACKAGES_TETRA"
    fi

    # build
    cd "$IMAGEBUILDER_FOLDER"
    make image PROFILE="$1" PACKAGES="$selected_packages" FILES="$BUILD_FOLDER/rootfs" BIN_DIR="$BUILD_FOLDER/release"
    #cp "$IMAGEBUILDER_FOLDER/bin/targets/*/*/*-squashfs-sysupgrade.bin" "$BUILD_FOLDER/release"
}



# implement this shitty logic
printf "Universal Wifi pineapple hardware cloner - builder\n"
printf "************************************** by DSR!\n\n"

prepare_build
build "$PROFILE"
#rename "s/openwrt-$OPENWRT_VERSION-ar71xx-generic-//" bin/targets/*/generic/*-squashfs-sysupgrade.bin
#rename "s/squashfs/tetra/" ../tetra-releases/*.bin
