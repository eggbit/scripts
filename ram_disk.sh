#!/bin/bash

RAMDISK_NAME="ramdisk2"
RAMDISK_SIZE=4194304 # megabytes_you_want * 2048

CACHE_PATHS=(
    ~/library/caches/com.apple.safari
    ~/library/caches/google/chrome/default/cache
    # ~/library/caches/com.spotify.client/storage
    ~/library/caches/com.spotify.client/data
)

rand() {
    eval dd if=/dev/random count=1 2>/dev/null | md5 | cut -c 1-4
}

# $1 = path to move
move_to_ram() {
    local ramdisk_path
    ramdisk_path="/Volumes/$RAMDISK_NAME/$(rand)/$(basename "$1")"

    mkdir -p "$ramdisk_path"

    if [[ -d "$1" ]]; then
        mv "$1" "$(dirname "$ramdisk_path")"
    fi

    ln -sf "$ramdisk_path" "$1"
}

# If ramdisk already exists, unmount it first.
if [[ -n $(ls /volumes/$RAMDISK_NAME 2> /dev/null) ]]; then
    echo "Unmounting current ramdisk..."
    $(umount /volumes/$RAMDISK_NAME)
fi

# echo "Creating 2GB ramdisk..."
diskutil erasevolume HFS+ "$RAMDISK_NAME" $(hdiutil attach -nomount ram://$RAMDISK_SIZE)

for i in "${CACHE_PATHS[@]}"
do
    echo "Moving to $RAMDISK_NAME: $i"
    move_to_ram "$i"
done

echo "Done!"
