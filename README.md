![Project Logo](https://i.imgur.com/a1HXxMm.png)

# Universal Wifi pineapple hardware cloner

The Pineapple NANO and TETRA were excellent security hardware but in 2020 they reached their end of life.
So to give a new life to this platform in more modern hardware, I've made these scripts.

Sometime between 2019 and 2020 we started using the private beta of this project which we called "Pineapple Termidor" 🤣


## Builds

I made a [second repo](https://github.com/xchwarze/wifi-pineapple-cloner-builds) where you can find the firmwares already made for the devices of the "Supported devices"<br>
If you want to collaborate by adding a new device to the list or adding improvements to them, you can do so through a pull request to this repo.


## Build steps

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
tools/copier.sh lists/$FLAVOR.filelist rootfs-base rootfs

# fix files
chmod +x tools/fs-patcher.sh
tools/fs-patcher.sh rootfs nano
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
root@192.168.1.1's password: 
gl-ar150-pineapple-nano.bin                                                                        100%   13MB   2.2MB/s   00:05 

# Once the image is uploaded execute sysupgrade command to update firmware
ssh root@192.168.1.1
sysupgrade -n -F /tmp/gl-ar150-pineapple-nano.bin
```


## Supported devices

Pineapple NANO compatible hardware.
This is a uncomplete list!

Brand       | Device         | CPU (MHz)         | Flash (MB) | RAM (MB) | More info | Download build |
-------------|-------------|-----------|-----------|-----------|-----------|-----------|
Buffalo  | WZR-450HP2 | 400 | 32 | 64 | [[openwrt]](https://openwrt.org/toh/buffalo/wzr-450hp2) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/nano-releases/wzr-450hp2-nano-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/nano-releases/wzr-450hp2-nano-mini-sysupgrade.bin)
Buffalo  | WZR-HP-G300NH v1 | 400 | 32 | 64 | [[openwrt]](https://openwrt.org/toh/hwdata/buffalo/buffalo_wzr-hp-g300nh_v1) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/nano-releases/wzr-hp-g300nh-nano-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/nano-releases/wzr-hp-g300nh-nano-mini-sysupgrade.bin)
Buffalo  | WZR-HP-G450H v1 | 400 | 32 | 64 | [[openwrt]](https://openwrt.org/toh/hwdata/buffalo/buffalo_wzr-hp-g450h_v1) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/nano-releases/wzr-hp-g450h-nano-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/nano-releases/wzr-hp-g450h-nano-mini-sysupgrade.bin)
Buffalo  | WZR-HP-G300NH2 | 400 | 32 | 64 | [[openwrt]](https://openwrt.org/toh/hwdata/buffalo/buffalo_wzr-hp-g300nh2_v2) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/nano-releases/wzr-hp-g300nh2-nano-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/nano-releases/wzr-hp-g300nh2-nano-mini-sysupgrade.bin)
GL.iNet  | GL-AR150 | 400 | 16 | 64 | [[openwrt]](https://openwrt.org/toh/hwdata/gl.inet/gl.inet_gl-ar150) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/nano-releases/gl-ar150-nano-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/nano-releases/gl-ar150-nano-mini-sysupgrade.bin)
<br>

Pineapple TETRA compatible hardware.
This is a uncomplete list!

Brand       | Device         | CPU (MHz)         | Flash (MB) | RAM (MB) | More info | Download build |
-------------|-------------|-----------|-----------|-----------|-----------|-----------|
Buffalo  | WZR-600DHP | 680 | 32 | 128 | [[openwrt]](https://openwrt.org/toh/hwdata/buffalo/buffalo_wzr-600dhp) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wzr-600dhp-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wzr-600dhp-tetra-mini-sysupgrade.bin)
Buffalo  | WZR-HP-AG300H v1 | 680 | 32 | 128 | [[openwrt]](https://openwrt.org/toh/hwdata/buffalo/buffalo_wzr-hp-ag300h_v1) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wzr-hp-ag300h-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wzr-hp-ag300h-tetra-mini-sysupgrade.bin)
D-Link   | DGL-5500 A1 | 720 | 16 | 128 | [[openwrt]](https://openwrt.org/toh/hwdata/d-link/d-link_dgl-5500_a1) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/dgl-5500-a1-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/dgl-5500-a1-tetra-mini-sysupgrade.bin)
D-Link   | DIR-835 A1 | 560 | 16 | 128 | [[openwrt]](https://openwrt.org/toh/d-link/dir-835_a1) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/dir-835-a1-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/dir-835-a1-tetra-mini-sysupgrade.bin)
D-Link   | DIR-869 A1 | 750 | 16 | 64 | [[openwrt]](https://openwrt.org/toh/hwdata/d-link/d-link_dir-869_a1) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/dir-869-a1-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/dir-869-a1-tetra-mini-sysupgrade.bin)
GL.iNet  | GL-AR300 v3 | 560 | 16 | 128 | [[openwrt]](https://openwrt.org/toh/hwdata/gl.inet/gl.inet_gl-ar300) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar300-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar300-tetra-mini-sysupgrade.bin)
GL.iNet  | GL-AR300M | 650 | 16 | 128 | [[openwrt]](https://openwrt.org/toh/gl.inet/gl-ar300m) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar300m-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar300m-tetra-mini-sysupgrade.bin)
GL.iNet  | GL-AR750 | 650 | 16 | 128 | [[openwrt]](https://openwrt.org/toh/hwdata/gl.inet/gl.inet_gl-ar750) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar750-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar750-tetra-mini-sysupgrade.bin)
GL.iNet  | GL-AR750S v1 | 775 | 16 | 128 | [[openwrt]](https://openwrt.org/toh/hwdata/gl.inet/gl.inet_gl-ar750s) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar750s-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar750s-tetra-mini-sysupgrade.bin)
TP-Link  | Archer C7 v2 | 720 | 16 | 128 | [[openwrt]](https://openwrt.org/toh/hwdata/tp-link/tp-link_archer_c7_ac1750_v2.0) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/archer-c7-v2-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/archer-c7-v2-tetra-mini-sysupgrade.bin)
TP-Link  | Archer C7 v4 | 775 | 16 | 128 | [[openwrt]](https://openwrt.org/toh/hwdata/tp-link/tp-link_archer_c7_v4) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/archer-c7-v4-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/archer-c7-v4-tetra-mini-sysupgrade.bin)
TP-Link  | Archer C7 v5 | 750 | 16 | 128 | [[openwrt]](https://openwrt.org/toh/hwdata/tp-link/tp-link_archer_c7_v5) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/archer-c7-v5-tetra-sysupgrade.bin) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/archer-c7-v5-tetra-mini-sysupgrade.bin)
Zyxel  | NBG6716 | 720 | 16 + 256 | 256 | [[openwrt]](https://openwrt.org/toh/zyxel/nbg6716) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/nbg6716-tetra-sysupgrade.tar) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/nbg6716-tetra-mini-sysupgrade.tar)
NETGEAR  | R6100 | 560 | 128 | 128 | [[openwrt]](https://openwrt.org/toh/netgear/r6100) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/r6100-tetra-sysupgrade.tar) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/r6100-tetra-mini-sysupgrade.tar)
NETGEAR  | WNDR3700 V4 | 560 | 128 | 128 | [[openwrt]](https://openwrt.org/toh/netgear/wndr3700) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wndr3700v4-tetra-sysupgrade.tar) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wndr3700v4-tetra-mini-sysupgrade.tar)
NETGEAR  | WNDR4300 V1 | 560 | 128 | 128 | [[openwrt]](https://openwrt.org/toh/netgear/wndr4300) | [[normal]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wndr4300-tetra-sysupgrade.tar) [[mini]](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wndr4300-tetra-mini-sysupgrade.tar)
<br>


## Install steps

1. Install OpenWrt version 19.07.2 on your router
<br>

2. Use SCP to upload the image in your device
```bash
scp archer-c7-v5-tetra-sysupgrade.bin root@192.168.1.1:/tmp 
root@192.168.1.1's password: 
archer-c7-v5-tetra-sysupgrade.bin                                                                        100%   13MB   2.2MB/s   00:05 
```
<br>

3. Once the image is uploaded execute sysupgrade command to update firmware
```bash
ssh root@192.168.1.1
sysupgrade -n -F /tmp/archer-c7-v5-tetra-sysupgrade.bin
```
Now wait few minutes until the device install the new firmware
<br>

4. Enter to pineapple panel and enjoy! `http://172.16.42.1:1471/`

Note: 
If you are stuck at the message "The WiFi Pineapple is still booting" don't panic.
All you have to do is SSH into the AR150 with the username root and password you set originally
```bash
ssh root@172.16.42.1
jffs2reset -y && reboot
```
(Note the IP address must have change and the default password is root).


## Important notes

0. The original hardware is designed to have 2 Wi-Fi cards and have at least 2 gigabytes of disk space!
To meet these requirements you will have to:
* Add a flash drive
* In the case of the NANO, add a second Wi-Fi adapter. You can connect both with a usb hub!

1. As the tetra is intended to be used on hardware with 32MB of flash it is recommended to use it with a pendrive.
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

2. The original pineapple binaries are compiled with mips24kc and BE endianness.
So your target hardware must support the instructionset with this endianness. Check this in the [openwrt list of hardware](https://openwrt.org/docs/techref/instructionset/mips_24kc).
<br>

3. The original pineapple binaries are compiled with SSP ([Stack-Smashing Protection](https://openwrt.org/docs/guide-user/security/security-features)) 
Your version has to support it, so as not to have this type of errors:
```bash
[    7.383577] kmodloader: loading kernel modules from /etc/modules-boot.d/*
[    8.052737] crypto_hash: Unknown symbol __stack_chk_guard (err 0)
[    8.057461] crypto_hash: Unknown symbol __stack_chk_fail (err 0)
```
<br>

4. WiFi Pineapple use a modified version of:
```bash
/lib/netifd/wireless/mac80211.sh
/lib/netifd/hostapd.sh
/lib/wifi/mac80211.sh
```
You may have to make yours based on these.
<br>

5. Busybox applets list:
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
Don't forget to refactor the uses of uuencode with mpack! (reporting script)<br>


## Recomended setup
1. [GL-AR150](https://www.gl-inet.com/products/gl-ar150/) or [TPLink Archer C7](https://www.tp-link.com/en/home-networking/wifi-router/archer-c7/)
2. USB 2.0 [2 ports hub](https://www.ebay.com/itm/144520475350)
2. Generic [RT5370 WIFI adapter](https://www.ebay.com/itm/284904442887) **you're really going to need this for nano builds**
3. Please support Hak5 work and buy the original hardware


## If you want to collaborate with hardware 
To develop the next versions of this project I need:

For TETRA clone project:
https://www.gl-inet.com/products/gl-ar750s/#specs

For "WiFi Pineapple Mark 6.5" project:
https://www.gl-inet.com/products/gl-mt1300/#specs
