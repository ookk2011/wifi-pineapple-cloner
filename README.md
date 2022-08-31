# Universal Wifi pineapple hardware cloner

The Pineapple NANO and TETRA were excellent security hardware but in 2020 they reached their end of life.
So to give a new life to this platform in more modern hardware, I've made these scripts. 


## Builds

I made a [second repo](https://github.com/xchwarze/wifi-pineapple-cloner-builds) where you can find the firmwares already made for the devices of the "Supported devices"
If you want to collaborate by adding a new device to the list or adding improvements to them, you can do so through a pull request to this repo.


## Build steps

You can read the steps to do it with [tetra here](tetra.md)

1. Unpack firmware for get file system
```bash
# get fmk tool
git clone https://github.com/rampageX/firmware-mod-kit fmk-tool

# get target firmware (example pineapple nano)
wget https://www.wifipineapple.com/downloads/nano/latest -O nanofw.bin
fmk-tool/extract-firmware.sh nanofw.bin
sudo chown -R $USER fmk
mv fmk/rootfs rootfs-nano
rm -rf fmk
```

2. Get opkg packages list from openwrt file system
```bash
# get packages list
php opkg_statusdb_parser.php rootfs-nano/usr/lib/opkg/status
```

3. Generate openwrt extra files
```bash
# copy pineapple files
chmod +x copier.sh
./copier.sh nano.filelist rootfs-nano

# fix files
chmod +x nano-fixer.sh
./nano-fixer.sh
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
make image PROFILE=gl-ar150 PACKAGES="at autossh base-files block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iperf3 iwinfo kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-rtl8192cu kmod-scsi-generic kmod-usb-acm kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-qmi-wwan kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-net-smsc95xx kmod-usb-ohci kmod-usb-storage-extras kmod-usb-uhci kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgmp10 libiconv-full2 libintl libltdl7 libnet-1.2.x libnl200 libreadline8 libustream-mbedtls20150806 libxml2 logd macchanger mt7601u-firmware mtd nano ncat netcat nginx odhcp6c odhcpd-ipv6only openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps python-logging python-openssl python-sqlite3 rtl-sdr ssmtp tcpdump uboot-envtools uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear" FILES=../files/
cp bin/targets/ar71xx/generic/openwrt-19.07.2-ar71xx-generic-gl-ar150-squashfs-sysupgrade.bin ../gl-ar150-pineapple-nano.bin
```

5. Flash the target hardware with this custom firmware!


## Supported devices

This is a uncomplete list!

Brand       | Device         | CPU (MHZ)         | Flash MB| RAM MB | More info | Download |
-------------|-------------| -----------| -----------| -----------| -----------| -----------|
Buffalo  | WZR450HP2 | 400 | 32 | 64 | [docs link](https://openwrt.org/toh/buffalo/wzr-450hp2) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wzr-450hp2-tetra-sysupgrade.bin)
Buffalo  | WZR600DHP | 680 | 32 | 128 | [docs link](https://openwrt.org/toh/hwdata/buffalo/buffalo_wzr-600dhp) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wzr-600dhp-tetra-sysupgrade.bin)
Buffalo  | WZRHPAG300H | 680 | 32 | 128 | [docs link](https://openwrt.org/toh/hwdata/buffalo/buffalo_wzr-hp-ag300h_v1) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wzr-hp-ag300h-tetra-sysupgrade.bin)
Buffalo  | WZRHPG300NH | 400 | 32 | 64 | [docs link](https://openwrt.org/toh/hwdata/buffalo/buffalo_wzr-hp-g300nh_v1) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wzr-hp-g300nh-tetra-sysupgrade.bin)
Buffalo  | WZRHPG300NH2 | 400 | 32 | 64 | [docs link](https://openwrt.org/toh/hwdata/buffalo/buffalo_wzr-hp-g300nh2_v2) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wzr-hp-g300nh2-tetra-sysupgrade.bin)
Buffalo  | WZRHPG450H | 400 | 32 | 64 | [docs link](https://openwrt.org/toh/hwdata/buffalo/buffalo_wzr-hp-g450h_v1) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/wzr-hp-g450h-tetra-sysupgrade.bin)
D-Link   | DGL5500A1 | 720 | 16 | 128 | [docs link](https://openwrt.org/toh/hwdata/d-link/d-link_dgl-5500_a1) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/dgl-5500-a1-tetra-sysupgrade.bin)
D-Link   | DIR835A1 | 560 | 16 | 128 | [docs link](https://openwrt.org/toh/d-link/dir-835_a1) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/dir-835-a1-tetra-sysupgrade.bin)
D-Link   | dir-869-a1 | 750 | 16 | 64 | [docs link](https://openwrt.org/toh/hwdata/d-link/d-link_dir-869_a1) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/dir-869-a1-tetra-sysupgrade.bin)
GL.iNet  | gl-ar300 | 560 | 16 | 128 | [docs link](https://openwrt.org/toh/hwdata/gl.inet/gl.inet_gl-ar300) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar300-tetra-sysupgrade.bin)
GL.iNet  | gl-ar300m | 650 | 16 | 128 | [docs link](https://openwrt.org/toh/gl.inet/gl-ar300m) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar300m-tetra-sysupgrade.bin)
GL.iNet  | gl-ar750 | 650 | 16 | 128 | [docs link](https://openwrt.org/toh/hwdata/gl.inet/gl.inet_gl-ar750) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar750-tetra-sysupgrade.bin)
GL.iNet  | gl-ar750s | 775 | 16 | 128 | [docs link](https://openwrt.org/toh/hwdata/gl.inet/gl.inet_gl-ar750s) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/gl-ar750s-tetra-sysupgrade.bin)
TP-Link  | archer-c7-v2 | 720 | 16 | 128 | [docs link](https://openwrt.org/toh/hwdata/tp-link/tp-link_archer_c7_ac1750_v2.0) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/archer-c7-v2-tetra-sysupgrade.bin)
TP-Link  | archer-c7-v4 | 775 | 16 | 128 | [docs link](https://openwrt.org/toh/hwdata/tp-link/tp-link_archer_c7_v4) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/archer-c7-v4-tetra-sysupgrade.bin)
TP-Link  | archer-c7-v5 | 750 | 16 | 128 | [docs link](https://openwrt.org/toh/hwdata/tp-link/tp-link_archer_c7_v5) | [lastest version](https://github.com/xchwarze/wifi-pineapple-cloner-builds/blob/main/tetra-releases/archer-c7-v5-tetra-sysupgrade.bin)
<br>


## Important notes

1. The original pineapple binaries are compiled with mips24kc and BE endianness.
So your target hardware must support the instructionset with this endianness. [List of hardware](https://openwrt.org/docs/techref/instructionset/mips_24kc).

2. The original pineapple binaries are compiled with SSP ([Stack-Smashing Protection](https://openwrt.org/docs/guide-user/security/security-features)) 
Your version has to support it, so as not to have this type of errors:
```bash
[    7.383577] kmodloader: loading kernel modules from /etc/modules-boot.d/*
[    8.052737] crypto_hash: Unknown symbol __stack_chk_guard (err 0)
[    8.057461] crypto_hash: Unknown symbol __stack_chk_fail (err 0)
```

3. WiFi Pineapple use a modified version of: /lib/netifd/wireless/mac80211.sh /lib/netifd/hostapd.sh /lib/wifi/mac80211.sh
You may have to make yours based on these.

4. If you are stuck at the message "The WiFi Pineapple is still booting" don't panic, this is a known issue with running the WiFi Pineapple firmware on the AR150. All you have to do is ssh into the AR150 with the username root and password you set originally when you booted the AR150 right out of the box.
Executing the command jffs2reset -y && reboot should resolve your problems. 

5. Busybox applets list:
```
# openwrt: used 118 applets
ash cat chgrp chmod chown cp date dd df dmesg echo egrep false fgrep fsync grep gunzip gzip kill ln lock login ls mkdir mknod mktemp mount mv netmsg netstat nice passwd pidof ping ping6 ps pwd rm rmdir sed sh sleep sync tar touch traceroute traceroute6 true umount uname vi zcat halt hwclock ifconfig ip mkswap pivot_root poweroff reboot route start-stop-daemon swapoff swapon switch_root sysctl udhcpc awk basename bunzip2 bzcat clear cmp crontab cut dirname du env expr find flock free head hexdump id killall less logger md5sum mkfifo nc nslookup pgrep printf readlink reset seq sha256sum sort strings tail tee test time top tr uniq uptime wc which xargs yes [ [[ brctl chroot crond ntpd 

# nano: used 114 applets
ash bash cat chgrp chmod chown cp date dd df dmesg echo egrep false fgrep fsync grep gunzip gzip kill ln lock login ls mkdir mknod mktemp mount mv netmsg netstat nice passwd pidof ping ping6 pwd rm rmdir sed sh sleep sync tar touch traceroute true umount uname vi fdisk halt hwclock ifconfig ip mkswap pivot_root poweroff reboot route start-stop-daemon swapoff swapon switch_root sysctl udhcpc awk basename clear cmp crontab cut dirname du env expr find flock free head hexdump id killall less logger md5sum mkfifo nslookup pgrep printf readlink reset seq sha256sum sort tail tee test time top tr uniq uptime uuencode wc which xargs yes [ [[ brctl chroot crond ntpd 

# tetra: used 118 applets
ash cat chgrp chmod chown cp date dd df dmesg echo egrep false fgrep fsync grep gunzip gzip kill ln lock login ls mkdir mknod mktemp mount mv netmsg netstat nice passwd pidof ping ping6 pwd rm rmdir sed sh sleep sync tar touch traceroute traceroute6 true umount uname vi zcat fdisk halt hwclock ifconfig ip mkswap pivot_root poweroff reboot route start-stop-daemon swapoff swapon switch_root sysctl udhcpc awk basename bunzip2 bzcat clear cmp crontab cut dirname du env expr find flock free head hexdump id killall less logger md5sum mkfifo nslookup pgrep printf readlink reset seq sha256sum sort strings tail tee test time top tr uniq uptime uuencode wc which xargs yes [ [[ brctl chroot crond ntpd 
```
Diferences with Openwrt Busybox build
```
Nano build
--------------------
Remove: bunzip2 bzcat nc ps strings traceroute6 zcat
Add: bash fdisk uuencode

Tetra build
--------------------
Remove: nc ps
Add: fdisk uuencode
```
If you don't want to do a custom Busybox build you can install fdisk and mpack.
Don't forget to refactor the uses of uuencode! (reporting script) 


## Recomended setup
1. GL-AR150 https://www.gl-inet.com/products/gl-ar150/ or TPLink Archer C7
2. USB 2.0 2 ports hub https://www.ebay.co.uk/itm/USB-2-0-2-Dual-Port-Hub-For-Laptop-Macbook-Notebook-PC-Mouse-Flash-Disk/273070654192
2. Generic RT5370 adapter
3. Please support Hak5 work and buy the original hardware


## If you want to collaborate with hardware 
To develop the next versions of this project I need:

For TETRA clone project:
https://www.gl-inet.com/products/gl-ar750s/#specs

For "WiFi Pineapple Mark 6.5" project:
https://www.gl-inet.com/products/gl-mt1300/#specs
