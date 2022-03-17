## Build steps for gl-ar300m

These steps are not tested by me. Surely some more modifications will have to be made once flashed on gl-ar300m. 

1. Unpack firmware for get file system
```bash
# install binwalk
# https://github.com/ReFirmLabs/binwalk

# get target firmware
wget https://www.wifipineapple.com/downloads/tetra/latest -O tetrafw.bin
binwalk tetrafw.bin -e 
binwalk _tetrafw.bin.extracted/sysupgrade-pineapple-tetra/root -e --preserve-symlinks
mv _tetrafw.bin.extracted/sysupgrade-pineapple-tetra/_root.extracted/squashfs-root/ rootfs-tetra
```

2. Get opkg packages list from openwrt file system
```bash
# get packages list
php opkg_statusdb_parser.php rootfs-tetra/usr/lib/opkg/status
```

3. Generate openwrt extra files
```bash
# copy pineapple files
chmod +x copier.sh
./copier.sh tetra.filelist rootfs-tetra

# fix files
chmod +x tetra-fixer.sh
./tetra-fixer.sh
```

4. Build your custom build
```bash
# for this poc use openwrt imagebuilder v19.07.2 for ar71xx
wget https://downloads.openwrt.org/releases/19.07.2/targets/ar71xx/generic/openwrt-imagebuilder-19.07.2-ar71xx-generic.Linux-x86_64.tar.xz
tar xJf openwrt-imagebuilder-19.07.2-ar71xx-generic.Linux-x86_64.tar.xz
cd openwrt-imagebuilder-19.07.2-ar71xx-generic.Linux-x86_64

# based on step 2 data!
make image PROFILE=gl-ar300m PACKAGES="at autossh base-files bash block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iwinfo kmod-ath kmod-ath9k kmod-ath9k-htc kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-lib-crc-itu-t kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-rtl8192cu kmod-scsi-generic kmod-usb-acm kmod-usb-ledtrig-usbport kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-rndis kmod-usb-ohci kmod-usb-serial-pl2303 kmod-usb-storage-extras kmod-usb-uhci kmod-usb-wdm kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgdbm libgmp10 libiconv-full2 libltdl7 libnet-1.2.x libnl200 libustream-mbedtls20150806 libxml2 logd macchanger mtd nano ncat netcat nginx openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps python-logging python-openssl python-sqlite3 rtl-sdr ssmtp tcpdump-mini uboot-envtools uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear" FILES=../files/
cp bin/targets/ar71xx/generic/openwrt-19.07.2-ar71xx-generic-gl-ar300m-squashfs-sysupgrade.bin ../gl-ar300m-pineapple-nano.bin
```

5. Flash the target hardware with this custom firmware!