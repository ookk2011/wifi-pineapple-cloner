#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

if [[ "$1" == "" || "$2" == "" ]]; then
    echo "Argument missing! Run with \"copier.sh [FILE_LIST] [FROM_FOLDER]\""
    exit 1
fi

FILE_LIST="$1"
FROM_FOLDER="$2"
TO_FOLDER="rootfs"
COUNTER=0

echo "[*] Start copy loop"
rm -rf "$TO_FOLDER"
mkdir "$TO_FOLDER"

for FILE in $(cat "$FILE_LIST")
do
    if [[ "${FILE:0:1}" != '/' ]]; then
        continue
    fi
    
    # fix name chars
    FILE=$(echo $FILE | sed $'s/\r//')

    # check exist
    if [[ ! -f "$FROM_FOLDER$FILE" ]]; then
        printf "[!] File does not exist: %s\n" "$FROM_FOLDER$FILE"
        continue
    fi

    # check file type
    #TYPE_CHECK=$(file "$FROM_FOLDER$FILE" | grep "ELF")
    #if [[ $TYPE_CHECK != "" ]]; then
    #    printf "[+] ELF: %s\n" "$FILE"
    #    continue
    #fi

    let COUNTER++

    FOLDER=$(dirname $FILE)
    mkdir -p "$TO_FOLDER$FOLDER"

    # if folder...
    if [[ -d "$FROM_FOLDER$FILE" ]]; then
        cp -R "$FROM_FOLDER$FILE" "$TO_FOLDER$FILE"
    else
        cp -P "$FROM_FOLDER$FILE" "$TO_FOLDER$FILE"
    fi
done

printf "[*] Files copied: %d\n" $COUNTER
