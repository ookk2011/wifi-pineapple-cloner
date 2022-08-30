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

rm -rf "$TO_FOLDER"
mkdir "$TO_FOLDER"

for FILE in $(cat "$FILE_LIST")
do
    if [[ "${FILE:0:1}" != '/' ]]; then
        continue
    fi

    let COUNTER++
    
    # fix name chars
    FILE=$(echo $FILE | sed $'s/\r//')

    FOLDER=$(dirname $FILE)
    mkdir -p "$TO_FOLDER$FOLDER"

    # if folder...
    if [ -d "$FROM_FOLDER$FILE" ]; then
        cp -R "$FROM_FOLDER$FILE" "$TO_FOLDER$FILE"
    else
        cp -P "$FROM_FOLDER$FILE" "$TO_FOLDER$FILE"
    fi
done

printf "Files copied: %d\n" $COUNTER
