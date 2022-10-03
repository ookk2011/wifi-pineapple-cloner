#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

THEME="$1"
FS_FOLDER="$2"
declare -a TYPES=("default" "yinyang" "darkmode")
if [[ "$FS_FOLDER" != "" && ! -d "$FS_FOLDER" ]] || ! grep -q "$THEME" <<< "${TYPES[*]}"; then
    echo "Run with \"install.sh [THEME] [FS_FOLDER]\""
    echo "    THEME     -> must be one of these values: nano, tetra, universal"
    echo "    FS_FOLDER -> folder containing the fs to use"

    exit 1
fi



echo "Pineapple theme changer"
echo "by DSR!"
echo ""

echo "[*] Theme: $THEME"

if [[ ! -d "$FS_FOLDER/pineapple" ]]
then
    echo "Not found: /pineapple"
    exit 1
fi

baseurl="https://raw.githubusercontent.com/xchwarze/wifi-pineapple-cloner/master/themes/$THEME"
wget "$baseurl/bootstrap.min.css" -O "$FS_FOLDER/pineapple/css/bootstrap.min.css"
wget "$baseurl/main.css" -O "$FS_FOLDER/pineapple/css/main.css"
wget "$baseurl/logo.png" -O "$FS_FOLDER/pineapple/img/logo.png"
wget "$baseurl/throbber.gif" -O "$FS_FOLDER/pineapple/img/throbber.gif"

echo ""
echo "Done!"