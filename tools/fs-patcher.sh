#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

ROOT_FS="$1"
FLAVOR="$2"
FILES_FOLDER="$(realpath $(dirname $0))/../files"
ARCHITECTURE="mips"
declare -a TYPES=("nano" "tetra" "universal")
if [[ ! -d "$ROOT_FS" ]] || ! grep -q "$FLAVOR" <<< "${TYPES[*]}"; then
    echo "Run with \"fs-patcher.sh [FS_FOLDER] [FLAVOR]\""
    echo "    FS_FOLDER -> folder containing the fs to use"
    echo "    FLAVOR    -> must be one of these values: nano, tetra, universal"

    exit 1
fi



common_patch () {
    echo "[*] Device detection fix"

    # Fix "unknown operand" error
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/hotplug.d/block/20-sd"
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/hotplug.d/usb/30-sd"
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/init.d/pineapple"
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/rc.button/BTN_1"
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/rc.button/reset"
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/rc.local"
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/uci-defaults/90-firewall.sh"
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/uci-defaults/91-fstab.sh"
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/uci-defaults/92-system.sh"
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/uci-defaults/95-network.sh"
    sed -i 's/print $6/print $1/' "$ROOT_FS/etc/uci-defaults/97-pineapple.sh"
    sed -i 's/print $6/print $1/' "$ROOT_FS/sbin/led"

    # Force setup
    sed -i 's/..Get Device/device="NANO"/' "$ROOT_FS/etc/rc.button/BTN_1"
    sed -i 's/..Get Device/device="NANO"/' "$ROOT_FS/etc/rc.button/reset"
    sed -i 's/..Get Device/device="NANO"/' "$ROOT_FS/etc/rc.local"
    sed -i 's/..Get Version and Device/device="TETRA"/' "$ROOT_FS/etc/uci-defaults/90-firewall.sh"
    sed -i 's/..Get Version and Device/device="NANO"/' "$ROOT_FS/etc/uci-defaults/91-fstab.sh"
    sed -i 's/..Get Version and Device/device="NANO"/' "$ROOT_FS/etc/uci-defaults/95-network.sh"
    sed -i 's/..Get Version and Device/device="NANO"/' "$ROOT_FS/etc/uci-defaults/97-pineapple.sh"
    sed -i 's/..Get device type/device="NANO"/' "$ROOT_FS/etc/uci-defaults/92-system.sh"
    #sed -i 's/..led (C) Hak5 2018/device="NANO"/' "$ROOT_FS/sbin/led"


    #echo "[*] Leds path fix"
    #
    #sed -i 's/wifi-pineapple-nano:blue:system/gl-ar150:orange:wlan/' "$ROOT_FS/sbin/led"
    #sed -i 's/wifi-pineapple-nano:blue:system/gl-ar150:orange:wlan/' "$ROOT_FS/etc/uci-defaults/92-system.sh"
    #sed -i 's/wifi-pineapple-nano:blue:system/gl-ar150:orange:wlan/' "$ROOT_FS/etc/uci-defaults/97-pineapple.sh"


    echo "[*] Pineapd fix"

    cp "$FILES_FOLDER/$ARCHITECTURE/pineapd" "$ROOT_FS/usr/sbin/pineapd"
    cp "$FILES_FOLDER/$ARCHITECTURE/pineap" "$ROOT_FS/usr/bin/pineap"
    chmod +x "$ROOT_FS/usr/sbin/pineapd"
    chmod +x "$ROOT_FS/usr/bin/pineap"


    echo "[*] Add Karma support"

    mkdir -p "$ROOT_FS/lib/netifd/wireless"
    cp "$FILES_FOLDER/common/karma/mac80211.sh" "$ROOT_FS/lib/netifd/wireless/mac80211.sh"
    cp "$FILES_FOLDER/common/karma/hostapd.sh" "$ROOT_FS/lib/netifd/hostapd.sh"
    cp "$FILES_FOLDER/$ARCHITECTURE/hostapd_cli" "$ROOT_FS/usr/sbin/hostapd_cli"
    cp "$FILES_FOLDER/$ARCHITECTURE/wpad" "$ROOT_FS/usr/sbin/wpad"
    chmod +x "$ROOT_FS/lib/netifd/wireless/mac80211.sh"
    chmod +x "$ROOT_FS/lib/netifd/hostapd.sh"
    chmod +x "$ROOT_FS/usr/sbin/hostapd_cli"
    chmod +x "$ROOT_FS/usr/sbin/wpad"


    echo "[*] Panel fixs"

    # update panel code
    rm -rf "$ROOT_FS/pineapple"
    wget -q https://github.com/xchwarze/wifi-pineapple-panel/archive/refs/heads/master.zip -O updated-panel.zip
    unzip -q updated-panel.zip

    cp -r wifi-pineapple-panel-master/src/* "$ROOT_FS/"
    rm -rf wifi-pineapple-panel-master updated-panel.zip

    chmod +x "$ROOT_FS/etc/init.d/pineapd"
    chmod +x "$ROOT_FS/etc/uci-defaults/93-pineap.sh"
    chmod +x "$ROOT_FS/pineapple/modules/Advanced/formatSD/format_sd"
    chmod +x "$ROOT_FS/pineapple/modules/Help/files/debug"
    chmod +x "$ROOT_FS/pineapple/modules/PineAP/executable/executable"
    chmod +x "$ROOT_FS/pineapple/modules/Reporting/files/reporting"
    rm -f "$ROOT_FS/pineapple/fix-executables.sh"

    cp "$FILES_FOLDER/common/panel/favicon.ico" "$ROOT_FS/pineapple/img/favicon.ico"
    cp "$FILES_FOLDER/common/panel/favicon-16x16.png" "$ROOT_FS/pineapple/img/favicon-16x16.png"
    cp "$FILES_FOLDER/common/panel/favicon-32x32.png" "$ROOT_FS/pineapple/img/favicon-32x32.png"

    sed -i 's/>Bulletins</>News</' "$ROOT_FS/pineapple/modules/Dashboard/module.html"
    sed -i 's/Load Bulletins from Hak5/Load project news!/' "$ROOT_FS/pineapple/modules/Dashboard/module.html"
    sed -i 's/www.wifipineapple.com\/{$device}\/bulletin/raw.githubusercontent.com\/xchwarze\/wifi-pineapple-cloner\/master\/updates.json/' "$ROOT_FS/pineapple/modules/Dashboard/api/module.php"
    sed -i 's/Error connecting to WiFiPineapple.com/Error connecting to GitHub.com!/' "$ROOT_FS/pineapple/modules/Dashboard/api/module.php"

    # fix docs size
    truncate -s 0 "$ROOT_FS/pineapple/modules/Setup/eula.txt"
    truncate -s 0 "$ROOT_FS/pineapple/modules/Setup/license.txt"


    echo "[*] Change Community Repositories URL"

    sed -i 's/from Hak5 Community Repositories//' "$ROOT_FS/pineapple/modules/ModuleManager/module.html"
    sed -i 's/www.wifipineapple.com\/{$device}\/modules/raw.githubusercontent.com\/xchwarze\/wifi-pineapple-modules\/master\/build/' "$ROOT_FS/pineapple/modules/ModuleManager/api/module.php"
    sed -i 's/\/build"/\/build\/modules.json"/' "$ROOT_FS/pineapple/modules/ModuleManager/api/module.php"
    sed -i 's/WiFiPineapple.com/GitHub.com/' "$ROOT_FS/pineapple/modules/ModuleManager/api/module.php"
    sed -i "s/moduleName}' -O/moduleName}.tar.gz' -O/" "$ROOT_FS/pineapple/modules/ModuleManager/api/module.php"


    echo "[*] Other fixs"

    # fix default password: root
    sed -i 's/^\(root:\)[^:]*\(:.*\)$/\1$1$3DBtk82B$6EPlkFc9GQrtDwmzKsUn31\2/' "$ROOT_FS/etc/shadow"

    # fix uci-defaults
    cp "$FILES_FOLDER/common/92-system.sh" "$ROOT_FS/etc/uci-defaults/92-system.sh"
    cp "$FILES_FOLDER/common/95-network.sh" "$ROOT_FS/etc/uci-defaults/95-network.sh"
    cp "$FILES_FOLDER/common/97-pineapple.sh" "$ROOT_FS/etc/uci-defaults/97-pineapple.sh"

    # fix pendrive hotplug
    cp "$FILES_FOLDER/common/20-sd-universal" "$ROOT_FS/etc/hotplug.d/block/20-sd-universal"
    rm "$ROOT_FS/etc/hotplug.d/block/20-sd"
    rm "$ROOT_FS/etc/hotplug.d/usb/30-sd"

    # default wifi config
    cp "$FILES_FOLDER/common/mac80211.sh" "$ROOT_FS/lib/wifi/mac80211.sh"

    # copy clean version of led script
    cp "$FILES_FOLDER/common/led" "$ROOT_FS/sbin/led"
    chmod +x "$ROOT_FS/sbin/led"

    # fix banner info
    sed -i 's/\/       /\/ by DSR!/g' "$ROOT_FS/etc/banner"
    sed -i 's/19.07.2/19.07.7/g' "$ROOT_FS/etc/banner"
}

nano_patch () {
    # correct python-codecs version (from python-codecs_2.7.18-3_mips_24kc.ipk)
    mkdir -p "$ROOT_FS/usr/lib/python2.7/encodings"
    cp "$FILES_FOLDER/$ARCHITECTURE/python/encodings/__init__.pyc" "$ROOT_FS/usr/lib/python2.7/encodings/__init__.pyc"
    cp "$FILES_FOLDER/$ARCHITECTURE/python/encodings/aliases.pyc" "$ROOT_FS/usr/lib/python2.7/encodings/aliases.pyc"
    cp "$FILES_FOLDER/$ARCHITECTURE/python/encodings/base64_codec.pyc" "$ROOT_FS/usr/lib/python2.7/encodings/base64_codec.pyc"
    cp "$FILES_FOLDER/$ARCHITECTURE/python/encodings/hex_codec.pyc" "$ROOT_FS/usr/lib/python2.7/encodings/hex_codec.pyc"

    # Panel changes
    sed -i "s/\$data = file_get_contents('\/proc\/cpuinfo')/return 'nano'/" "$ROOT_FS/pineapple/api/pineapple.php"
    sed -i "s/exec(\"cat \/proc\/cpuinfo | grep 'machine'\")/'nano'/" "$ROOT_FS/usr/bin/pineapple/site_survey"
}

tetra_patch () {
    # correct python-codecs version (from python-codecs_2.7.18-3_mips_24kc.ipk)
    mkdir -p "$ROOT_FS/usr/lib/python2.7/encodings"
    cp "$FILES_FOLDER/$ARCHITECTURE/python/encodings/__init__.pyc" "$ROOT_FS/usr/lib/python2.7/encodings/__init__.pyc"
    cp "$FILES_FOLDER/$ARCHITECTURE/python/encodings/aliases.pyc" "$ROOT_FS/usr/lib/python2.7/encodings/aliases.pyc"
    cp "$FILES_FOLDER/$ARCHITECTURE/python/encodings/base64_codec.pyc" "$ROOT_FS/usr/lib/python2.7/encodings/base64_codec.pyc"
    cp "$FILES_FOLDER/$ARCHITECTURE/python/encodings/hex_codec.pyc" "$ROOT_FS/usr/lib/python2.7/encodings/hex_codec.pyc"

    # Panel changes
    sed -i 's/tetra/nulled/' "$ROOT_FS/pineapple/js/directives.js"
    sed -i 's/tetra/nulled/' "$ROOT_FS/pineapple/modules/ModuleManager/js/module.js"
    sed -i 's/tetra/nulled/' "$ROOT_FS/pineapple/modules/Advanced/module.html"
    sed -i 's/nano/tetra/' "$ROOT_FS/pineapple/html/install-modal.html"
    sed -i 's/nano/tetra/' "$ROOT_FS/pineapple/modules/Advanced/module.html"
    sed -i 's/nano/tetra/' "$ROOT_FS/pineapple/modules/ModuleManager/js/module.js"
    sed -i 's/nano/tetra/' "$ROOT_FS/pineapple/modules/Reporting/js/module.js"
    sed -i 's/nano/tetra/' "$ROOT_FS/pineapple/modules/Reporting/api/module.php"
    sed -i "s/\$data = file_get_contents('\/proc\/cpuinfo')/return 'tetra'/" "$ROOT_FS/pineapple/api/pineapple.php"
    sed -i "s/exec(\"cat \/proc\/cpuinfo | grep 'machine'\")/'tetra'/" "$ROOT_FS/usr/bin/pineapple/site_survey"

    # fix banner info
    sed -i 's/DEVICE/TETRA/' "$ROOT_FS/etc/banner"
}

universal_patch () {
    # Panel changes
    sed -i 's/tetra/nulled/' "$ROOT_FS/pineapple/js/directives.js"
    sed -i 's/tetra/nulled/' "$ROOT_FS/pineapple/modules/ModuleManager/js/module.js"
    sed -i 's/tetra/nulled/' "$ROOT_FS/pineapple/modules/Advanced/module.html"
    sed -i 's/nano/tetra/' "$ROOT_FS/pineapple/html/install-modal.html"
    sed -i 's/nano/tetra/' "$ROOT_FS/pineapple/modules/Advanced/module.html"
    sed -i 's/nano/tetra/' "$ROOT_FS/pineapple/modules/ModuleManager/js/module.js"
    sed -i 's/nano/tetra/' "$ROOT_FS/pineapple/modules/Reporting/js/module.js"
    sed -i 's/nano/tetra/' "$ROOT_FS/pineapple/modules/Reporting/api/module.php"
    sed -i "s/\$data = file_get_contents('\/proc\/cpuinfo')/return 'tetra'/" "$ROOT_FS/pineapple/api/pineapple.php"
    sed -i "s/exec(\"cat \/proc\/cpuinfo | grep 'machine'\")/'tetra'/" "$ROOT_FS/usr/bin/pineapple/site_survey"

    # fix banner info
    sed -i 's/DEVICE/OMEGA/' "$ROOT_FS/etc/banner"
}



# implement....
echo "Universal Wifi pineapple hardware cloner"
echo "by DSR!"
echo ""

# apply patchs in order
common_patch

echo "[*] Setting target as: $FLAVOR"
if [[ $FLAVOR = 'nano' ]]
then
    nano_patch
elif [[ $FLAVOR = 'tetra' ]]
then
    tetra_patch
elif [[ $FLAVOR = 'universal' ]]
then
    universal_patch
fi

echo ""
echo "Done!"
