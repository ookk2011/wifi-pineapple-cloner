#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

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

  if [ ! -f "imagebuilder-19.07.2-ar71xx-nand.tar.xz" ]; then
    wget https://downloads.openwrt.org/releases/19.07.2/targets/ar71xx/nand/openwrt-imagebuilder-19.07.2-ar71xx-nand.Linux-x86_64.tar.xz -O imagebuilder-19.07.2-ar71xx-nand.tar.xz
  fi

  rm -rf imagebuilder-19.07.2-ar71xx-nand
  tar xJf imagebuilder-19.07.2-ar71xx-nand.tar.xz
  mv openwrt-imagebuilder-19.07.2-ar71xx-nand.Linux-x86_64 imagebuilder-19.07.2-ar71xx-nand

  # fix imagebuilder problems
  #sed -i 's/downloads.openwrt.org/archive.openwrt.org/' imagebuilder-19.07.2-ar71xx/repositories.conf
  #sed -i 's/downloads.openwrt.org/archive.openwrt.org/' imagebuilder-19.07.2-ar71xx-nand/repositories.conf
  wget https://archive.openwrt.org/releases/19.07.2/packages/mips_24kc/base/libubus20191227_2019-12-27-041c9d1c-1_mips_24kc.ipk -O imagebuilder-19.07.2-ar71xx/packages/libubus20191227_2019-12-27-041c9d1c-1_mips_24kc.ipk
  wget https://archive.openwrt.org/releases/19.07.2/packages/mips_24kc/base/libubus20191227_2019-12-27-041c9d1c-1_mips_24kc.ipk -O imagebuilder-19.07.2-ar71xx-nand/packages/libubus20191227_2019-12-27-041c9d1c-1_mips_24kc.ipk

  printf "Install script end!\n"
}

printf "Universal Wifi pineapple hardware - dependencies\n"
printf "************************************** by DSR!\n\n"

if [ "$1" == "openwrt-deps" ]
then
  install_openwrt_deps
elif [ "$1" == "ubuntu-deps" ]
then
  install_ubuntu_deps
else
  printf "Valid command:\n"
  printf "openwrt-deps  -> install imagebuilder and configure it\n"
  printf "ubuntu-deps   -> install ubuntu dependencies\n"
fi
