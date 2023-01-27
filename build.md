## Build steps

Note: All these steps are automated in `dependencies-install.sh` and `builder.sh`
```bash
chmod +x tools/*.sh
tools/dependencies-install.sh openwrt-deps-mips
sudo tools/dependencies-install.sh ubuntu-deps
tools/builder.sh mips universal imagebuilder-19.07.7-ar71xx-generic gl-ar750s
```

1. Unpack firmware for get file system
```bash
# install last version of binwalk first!
# https://github.com/ReFirmLabs/binwalk

# tetra
#wget https://www.wifipineapple.com/downloads/tetra/latest -O basefw.bin
#binwalk basefw.bin -e 
#binwalk _basefw.bin.extracted/sysupgrade-pineapple-tetra/root -e --preserve-symlinks
#mv _basefw.bin.extracted/sysupgrade-pineapple-tetra/_root.extracted/squashfs-root/ rootfs-base

# nano
wget https://www.wifipineapple.com/downloads/nano/latest -O basefw.bin
binwalk basefw.bin -e --preserve-symlinks
mv _basefw.bin.extracted/squashfs-root/ rootfs-base
```

2. Get opkg packages list from openwrt file system
```bash
# get packages list
php tools/opkg-parser.php rootfs-base/usr/lib/opkg/status
```

3. Generate openwrt extra files
```bash
# copy pineapple files
chmod +x tools/copier.sh
tools/copier.sh lists/nano.filelist rootfs-base rootfs

# fix files
chmod +x tools/fs-patcher.sh
tools/fs-patcher.sh mips rootfs nano
```

4. Build your custom build
```bash
# for this poc use openwrt imagebuilder v19.07.2 for ar71xx
wget https://downloads.openwrt.org/releases/19.07.2/targets/ar71xx/generic/openwrt-imagebuilder-19.07.2-ar71xx-generic.Linux-x86_64.tar.xz
tar xJf openwrt-imagebuilder-19.07.2-ar71xx-generic.Linux-x86_64.tar.xz
cd openwrt-imagebuilder-19.07.2-ar71xx-generic.Linux-x86_64

# based on step 2 data!
# ar71xx profile name: gl-ar150
# ath79 profile name: glinet_gl-ar150
make image PROFILE=gl-ar150 PACKAGES="at autossh base-files block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iperf3 iwinfo kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-rtl8192cu kmod-scsi-generic kmod-usb-acm kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-qmi-wwan kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-net-smsc95xx kmod-usb-ohci kmod-usb-storage-extras kmod-usb-uhci kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgmp10 libiconv-full2 libintl libltdl7 libnet-1.2.x libnl200 libreadline8 libustream-mbedtls20150806 libxml2 logd macchanger mt7601u-firmware mtd nano ncat netcat nginx odhcp6c odhcpd-ipv6only openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps python-logging python-openssl python-sqlite3 rtl-sdr ssmtp tcpdump uboot-envtools uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear" FILES=../rootfs
cp bin/targets/ar71xx/generic/openwrt-19.07.2-ar71xx-generic-gl-ar150-squashfs-sysupgrade.bin ../gl-ar150-pineapple-nano.bin
```

5. Flash the target hardware with this custom firmware!
```bash
# Use SCP to upload the image in your device
scp gl-ar150-pineapple-nano.bin root@192.168.1.1:/tmp 

# Once the image is uploaded execute sysupgrade command to update firmware
ssh root@192.168.1.1
sysupgrade -n -F /tmp/gl-ar150-pineapple-nano.bin
```


## Important notes

1. The original hardware is designed to have 2 Wi-Fi cards and have at least 2 gigabytes of disk space!
To meet these requirements you will have to:
* Add a flash drive
* In the case of the NANO, add a second Wi-Fi adapter. You can connect both with a usb hub!

2. As the tetra is intended to be used on hardware with 32MB of flash it is recommended to use it with a pendrive.
The steps for this would be:
* The pendrive has to be formatted from the pineapple panel `Advanced > USB & Storage > Format SD Card`
* Connect the pinneaple to the internet and restart it
* When pineapple starts it will run the [20-sd-tetra-fix script](https://github.com/xchwarze/wifi-pineapple-cloner/blob/master/fixs/tetra/20-sd-tetra-fix) and install the missing packages on the pendrive


This can be done manually by running this command:
```bash
opkg update && opkg --dest sd install python-logging python-openssl python-sqlite3 python-codecs && python -m compileall
```

However this is completely optional because pineapple will work fine without those packages.
Although we would need the pendrive to be able to install the modules...!

3. The original pineapple binaries are compiled with mips24kc and BE endianness.
So your target hardware must support the instructionset with this endianness. Check this in the [openwrt list of hardware](https://openwrt.org/docs/techref/instructionset/mips_24kc).
<br>

4. The original pineapple binaries are compiled with SSP ([Stack-Smashing Protection](https://openwrt.org/docs/guide-user/security/security-features)) 
Your version has to support it, so as not to have this type of errors:
```bash
[    7.383577] kmodloader: loading kernel modules from /etc/modules-boot.d/*
[    8.052737] crypto_hash: Unknown symbol __stack_chk_guard (err 0)
[    8.057461] crypto_hash: Unknown symbol __stack_chk_fail (err 0)
```
<br>

5. WiFi Pineapple use a modified version of:
```bash
/lib/netifd/wireless/mac80211.sh
/lib/netifd/hostapd.sh
/lib/wifi/mac80211.sh
```
You may have to make yours based on these.
<br>

6. Busybox applets list:
```
# openwrt: used 118 applets
[ [[ ash awk basename brctl bunzip2 bzcat cat chgrp chmod chown chroot clear cmp cp crond crontab cut date dd df dirname dmesg du echo egrep env expr false fgrep find flock free fsync grep gunzip gzip halt head hexdump hwclock id ifconfig ip kill killall less ln lock logger login ls md5sum mkdir mkfifo mknod mkswap mktemp mount mv nc netmsg netstat nice nslookup ntpd passwd pgrep pidof ping ping6 pivot_root poweroff printf ps pwd readlink reboot reset rm rmdir route sed seq sh sha256sum sleep sort start-stop-daemon strings swapoff swapon switch_root sync sysctl tail tar tee test time top touch tr traceroute traceroute6 true udhcpc umount uname uniq uptime vi wc which xargs yes zcat

# nano: used 116 applets
[ [[ ash awk basename bash brctl cat chgrp chmod chown chroot clear cmp cp crond crontab cut date dd df dirname dmesg du echo egrep env expr false fdisk fgrep find flock free fsync grep gunzip gzip halt head hexdump hwclock id ifconfig ip kill killall less ln lock logger login ls md5sum mkdir mkfifo mknod mkswap mktemp mount mv nc netmsg netstat nice nslookup ntpd passwd pgrep pidof ping ping6 pivot_root poweroff printf ps pwd readlink reboot reset rm rmdir route sed seq sh sha256sum sleep sort start-stop-daemon swapoff swapon switch_root sync sysctl tail tar tee test time top touch tr traceroute true udhcpc umount uname uniq uptime uuencode vi wc which xargs yes

# tetra: used 120 applets
[ [[ ash awk basename brctl bunzip2 bzcat cat chgrp chmod chown chroot clear cmp cp crond crontab cut date dd df dirname dmesg du echo egrep env expr false fdisk fgrep find flock free fsync grep gunzip gzip halt head hexdump hwclock id ifconfig ip kill killall less ln lock logger login ls md5sum mkdir mkfifo mknod mkswap mktemp mount mv nc netmsg netstat nice nslookup ntpd passwd pgrep pidof ping ping6 pivot_root poweroff printf ps pwd readlink reboot reset rm rmdir route sed seq sh sha256sum sleep sort start-stop-daemon strings swapoff swapon switch_root sync sysctl tail tar tee test time top touch tr traceroute traceroute6 true udhcpc umount uname uniq uptime uuencode vi wc which xargs yes zcat
```

Diferences with Openwrt Busybox build
```
Nano build
--------------------
Remove: bunzip2 bzcat strings traceroute6 zcat
Add: bash fdisk uuencode

Tetra build
--------------------
Remove: (nothing was removed)
Add: fdisk uuencode
```

If you don't want to do a custom Busybox build you can install `fdisk` and `mpack`.
Don't forget to refactor the uses of `uuencode` with `mpack`! (reporting script)<br>
