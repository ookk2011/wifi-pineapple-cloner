#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

OPENWRT_VERSION="19.07.7"
OPENWRT_BASE_URL="https://downloads.openwrt.org/releases/$OPENWRT_VERSION/targets"
declare -a OPENWRT_MIPS_TARGET_LIST=(
    "ar71xx-generic" "ar71xx-nand" "ath79-generic" "lantiq-xrx200"
)
declare -a OPENWRT_MIPSEL_TARGET_LIST=(
    "ramips-mt7620" "ramips-mt7621" "ramips-mt76x8"
)

install_openwrt_deps () {
    TARGET="$1"
    PACKAGES_ARQ="$2"

    FOLDER_NAME="imagebuilder-$OPENWRT_VERSION-$TARGET"
    ORIGINAL_FOLDER_NAME="openwrt-imagebuilder-$OPENWRT_VERSION-$TARGET.Linux-x86_64"
    FILE="$FOLDER_NAME.tar.xz"

    # download imagebuilder
    if [ ! -f "$FILE" ]; then
        echo "    [+] Downloading imagebuilder..."
        TYPE=$(echo $TARGET | sed "s/-/\//g")
        wget -q "$OPENWRT_BASE_URL/$TYPE/$ORIGINAL_FOLDER_NAME.tar.xz" -O "$FILE"
    fi

    # install...
    echo "    [+] Install imagebuilder..."
    rm -rf "$FOLDER_NAME"
    tar xJf "$FILE"
    mv "$ORIGINAL_FOLDER_NAME" "$FOLDER_NAME"

    # fix imagebuilder problems
    #echo "    [+] Fix missing dependencies"
    #wget -q "https://archive.openwrt.org/releases/$OPENWRT_VERSION/packages/$PACKAGES_ARQ/base/libubus20191227_2019-12-27-041c9d1c-1_$PACKAGES_ARQ.ipk" -O "$FOLDER_NAME/packages/libubus20191227_2019-12-27-041c9d1c-1_$PACKAGES_ARQ.ipk"

    # correct opkg feeds
    echo "    [+] Correct opkg feeds"
    sed -i "s/src\/gz openwrt_freifunk/#/" "$FOLDER_NAME/repositories.conf"
    sed -i "s/src\/gz openwrt_luci/#/" "$FOLDER_NAME/repositories.conf"
    sed -i "s/src\/gz openwrt_telephony/#/" "$FOLDER_NAME/repositories.conf"
}

install_ubuntu_deps () {
    printf "Install ubuntu deps...\n"
    printf "******************************\n"

    # install deps openwrt make and others
    apt-get install build-essential python2 wget gawk libncurses5-dev libncursesw5-dev zip rename -y

    # install binwalk
    git clone https://github.com/ReFirmLabs/binwalk
    cd binwalk && sudo python3 setup.py install && sudo ./deps.sh

    printf "\nInstall script end!\n"
}

install_openwrt_deps_mips () {
    printf "Install OpenWrt MIPS deps...\n"
    printf "******************************\n"

    for TARGET in ${OPENWRT_MIPS_TARGET_LIST[@]}; do
        printf "\n[*] Install: $TARGET\n"
        install_openwrt_deps $TARGET "mips_24kc"
    done

    printf "Install script end!\n"
}

install_openwrt_deps_mipsel () {
    printf "Install OpenWrt MIPSEL deps...\n"
    printf "******************************\n"

    for TARGET in ${OPENWRT_MIPSEL_TARGET_LIST[@]}; do
        printf "\n[*] Install: $TARGET\n"
        install_openwrt_deps $TARGET "mipsel_24kc"
    done

    printf "\nInstall script end!\n"
}



printf "Universal Wifi pineapple hardware - dependencies\n"
printf "************************************** by DSR!\n\n"

if [ "$1" == "openwrt-deps-mips" ]
then
    install_openwrt_deps_mips
elif [ "$1" == "openwrt-deps-mipsel" ]
then
    install_openwrt_deps_mipsel
elif [ "$1" == "ubuntu-deps" ]
then
    install_ubuntu_deps
else
    printf "Valid command:\n"
    printf "openwrt-deps-mips    -> install imagebuilders for mips and configure it\n"
    printf "openwrt-deps-mipsel  -> install imagebuilders for mipsel and configure it\n"
    printf "ubuntu-deps          -> install ubuntu dependencies\n"
fi
