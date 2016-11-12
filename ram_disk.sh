#!/bin/bash

RAMDISK_NAME="ramdisk_test"
RAMDISK_SIZE=524288 # megabytes_you_want * 2048
RAMDISK_USER=$1

CACHE_PATHS=(
    ~/library/caches/com.apple.safari/WebKitCache
    ~/library/caches/google/chrome/default/cache
    ~/library/caches/google/chrome\ canary/default/cache
    # ~/library/caches/com.spotify.client/storage
    # ~/library/caches/com.spotify.client/data
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
if [[ -d /volumes/$RAMDISK_NAME ]]; then
    # Clean up if the same ramdisk already exists.
    echo "Unmounting current ramdisk..."

    t=$(cat /volumes/$RAMDISK_NAME/mount)
    zpool destroy -f $RAMDISK_NAME && diskutil eject $t
fi

if [[ $1 ]]; then
    # Create, format, and mount new ramdisk
    RAMDISK_MOUNT=$(hdiutil attach -nomount ram://$RAMDISK_SIZE)
    zpool create -f -o ashift=12 -O casesensitivity=insensitive -O normalization=formD -O atime=off -O compression=lz4 -O checksum=off -O sync=disabled $RAMDISK_NAME $RAMDISK_MOUNT && \
    chown -R $RAMDISK_USER /volumes/$RAMDISK_NAME 2> /dev/null
    sleep 1
    rm -rf /volumes/$RAMDISK_NAME 2> /dev/null
    echo $RAMDISK_MOUNT > /volumes/$RAMDISK_NAME/mount
else
    echo "Pass username, please..."
fi
# Create, format, and mount ramdisk.

# diskutil erasevolume HFS+ "$RAMDISK_NAME" $(hdiutil attach -nomount ram://$RAMDISK_SIZE)

# for i in "${CACHE_PATHS[@]}"
# do
#     echo "Moving to $RAMDISK_NAME: $i"
#     move_to_ram "$i"
# done

echo "Done!"
