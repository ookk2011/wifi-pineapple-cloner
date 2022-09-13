#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

printf "Based on Archer C7 hardware!\n"
printf "by DSR!\n\n"


printf "Device detection fix\n"

# Fix "unknown operand" error
sed -i 's/print $6/print $1/' rootfs/etc/hotplug.d/block/20-sd
sed -i 's/print $6/print $1/' rootfs/etc/hotplug.d/usb/30-sd
sed -i 's/print $6/print $1/' rootfs/etc/init.d/pineapple
sed -i 's/print $6/print $1/' rootfs/etc/rc.button/BTN_1
sed -i 's/print $6/print $1/' rootfs/etc/rc.button/reset
sed -i 's/print $6/print $1/' rootfs/etc/rc.d/S98pineapple
sed -i 's/print $6/print $1/' rootfs/etc/rc.local
sed -i 's/print $6/print $1/' rootfs/etc/uci-defaults/90-firewall.sh
sed -i 's/print $6/print $1/' rootfs/etc/uci-defaults/91-fstab.sh
sed -i 's/print $6/print $1/' rootfs/etc/uci-defaults/92-system.sh
sed -i 's/print $6/print $1/' rootfs/etc/uci-defaults/95-network.sh
sed -i 's/print $6/print $1/' rootfs/etc/uci-defaults/97-pineapple.sh
sed -i 's/print $6/print $1/' rootfs/sbin/led

# Two scripts have TETRA because we have WAN port to play with.
sed -i 's/..Get Device/device="NANO"/' rootfs/etc/rc.button/BTN_1
sed -i 's/..Get Device/device="NANO"/' rootfs/etc/rc.button/reset
sed -i 's/..Get Device/device="NANO"/' rootfs/etc/rc.local
sed -i 's/..Get Version and Device/device="TETRA"/' rootfs/etc/uci-defaults/90-firewall.sh
sed -i 's/..Get Version and Device/device="NANO"/' rootfs/etc/uci-defaults/91-fstab.sh
sed -i 's/..Get Version and Device/device="TETRA"/' rootfs/etc/uci-defaults/95-network.sh
sed -i 's/..Get Version and Device/device="NANO"/' rootfs/etc/uci-defaults/97-pineapple.sh
sed -i 's/..Get device type/device="NANO"/' rootfs/etc/uci-defaults/92-system.sh


printf "Leds path fix\n"
sed -i 's/..led (C) Hak5 2018/device="NANO"/' rootfs/sbin/led
#sed -i 's/wifi-pineapple-nano:blue:system/tp-link:green:wps/' rootfs/sbin/led
#sed -i 's/wifi-pineapple-nano:blue:system/tp-link:green:wps/' rootfs/etc/uci-defaults/92-system.sh
#sed -i 's/wifi-pineapple-nano:blue:system/tp-link:green:wps/' rootfs/etc/uci-defaults/97-pineapple.sh


printf "Pineapd fix\n"
cp fixs/tetra/pineapd rootfs/usr/sbin/pineapd
cp fixs/tetra/pineap rootfs/usr/bin/pineap
chmod +x rootfs/usr/sbin/pineapd
chmod +x rootfs/usr/bin/pineap


printf "Add Karma support\n"
mkdir -p rootfs/lib/netifd/wireless
cp fixs/common/karma/mac80211.sh rootfs/lib/netifd/wireless/mac80211.sh
cp fixs/common/karma/hostapd.sh rootfs/lib/netifd/hostapd.sh
cp fixs/common/karma/hostapd_cli rootfs/usr/sbin/hostapd_cli
cp fixs/common/karma/wpad rootfs/usr/sbin/wpad
chmod +x rootfs/lib/netifd/wireless/mac80211.sh
chmod +x rootfs/lib/netifd/hostapd.sh
chmod +x rootfs/usr/sbin/hostapd_cli
chmod +x rootfs/usr/sbin/wpad


printf "Panel fixs\n"
# update panel code
rm -rf rootfs/pineapple
wget -q https://github.com/xchwarze/wifi-pineapple-panel/archive/refs/heads/master.zip -O updated-panel.zip
unzip -q updated-panel.zip

cp -r wifi-pineapple-panel-master/src/* rootfs/
rm -rf wifi-pineapple-panel-master updated-panel.zip

chmod +x rootfs/etc/init.d/pineapd
chmod +x rootfs/etc/uci-defaults/93-pineap.sh
chmod +x rootfs/pineapple/modules/Advanced/formatSD/format_sd
chmod +x rootfs/pineapple/modules/Help/files/debug
chmod +x rootfs/pineapple/modules/PineAP/executable/executable
chmod +x rootfs/pineapple/modules/Reporting/files/reporting
rm -f rootfs/pineapple/fix-executables.sh

cp fixs/common/panel/favicon.ico rootfs/pineapple/img/favicon.ico
cp fixs/common/panel/favicon-16x16.png rootfs/pineapple/img/favicon-16x16.png
cp fixs/common/panel/favicon-32x32.png rootfs/pineapple/img/favicon-32x32.png

sed -i 's/>Bulletins</>News</' rootfs/pineapple/modules/Dashboard/module.html
sed -i 's/Load Bulletins from Hak5/Load project news!/' rootfs/pineapple/modules/Dashboard/module.html
sed -i 's/www.wifipineapple.com\/{$device}\/bulletin/raw.githubusercontent.com\/xchwarze\/wifi-pineapple-cloner\/master\/updates.json/' rootfs/pineapple/modules/Dashboard/api/module.php
sed -i 's/Error connecting to WiFiPineapple.com/Error connecting to GitHub!/' rootfs/pineapple/modules/Dashboard/api/module.php

# Panel changes
sed -i 's/tetra/nulled/' rootfs/pineapple/js/directives.js
sed -i 's/tetra/nulled/' rootfs/pineapple/modules/ModuleManager/js/module.js
sed -i 's/nano/tetra/' rootfs/pineapple/modules/Advanced/module.html
sed -i 's/nano/tetra/' rootfs/pineapple/modules/ModuleManager/js/module.js
sed -i 's/nano/tetra/' rootfs/pineapple/modules/Reporting/js/module.js
sed -i 's/nano/tetra/' rootfs/pineapple/modules/Reporting/api/module.php
sed -i 's/unknown/tetra/' rootfs/pineapple/api/pineapple.php
sed -i "s/cat \/proc\/cpuinfo | grep 'machine'/echo 'tetra'/" rootfs/usr/bin/pineapple/site_survey

# fix docs size
truncate -s 0 rootfs/pineapple/modules/Setup/eula.txt
truncate -s 0 rootfs/pineapple/modules/Setup/license.txt


printf "Other fixs\n"
# fix default password: root
cp fixs/common/shadow rootfs/etc/shadow

# universal network config
cp fixs/common/95-network.sh rootfs/etc/uci-defaults/95-network.sh

# fix pendrive hotplug
cp fixs/tetra/20-sd-tetra-fix rootfs/etc/hotplug.d/block/20-sd-tetra-fix
rm rootfs/etc/hotplug.d/block/20-sd
rm rootfs/etc/hotplug.d/usb/30-sd

# fix default wifi config for use multiple wifi cards
cp fixs/common/mac80211.sh rootfs/lib/wifi/mac80211.sh

# fix hardware name in banner
sed -i 's/DEVICE\/$device/DEVICE\/TETRA/' rootfs/etc/uci-defaults/97-pineapple.sh


printf "\nDone!\n"
