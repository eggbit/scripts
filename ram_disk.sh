#!/bin/bash
RAMDISK_NAME="ramdisk"
RAMDISK_PATH="/volumes/$RAMDISK_NAME"
RAMDISK_SIZE=1048576 # megabytes_you_want * 2048
RAMDISK_USER=$1

CACHE_PATHS=(
    ~/library/caches/com.apple.safari/WebKitCache
    ~/library/caches/google/chrome/default/cache
    ~/library/caches/google/chrome\ canary/default/cache
)

# $1 = path to check
# $2 = name of ramdisk
ramdisk_check() {
    # If ramdisk already exists, unmount it first.
    if [[ -d $1 ]]; then
        echo "Unmounting current ramdisk..."

        MOUNT_POINT=$(cat $1/.mount)

        if hash zpool 2> /dev/null; then
            zpool destroy -f $2
        else
            diskutil unmountDisk force $1
        fi

        diskutil eject $MOUNT_POINT
    fi
}

# $1 = name of ramdisk
# $2 = size of ramdisk
ramdisk_mount() {
    local RAMDISK_MOUNT=$(hdiutil attach -nomount ram://$2)

    if hash zpool 2> /dev/null; then
        zpool create -f -o ashift=12 -O casesensitivity=insensitive -O normalization=formD -O atime=off -O compression=lz4 -O checksum=off -O sync=disabled $1 $RAMDISK_MOUNT
    else
        diskutil erasevolume HFS+ "$1" $RAMDISK_MOUNT
        diskutil disableJournal $RAMDISK_MOUNT
    fi

    echo $RAMDISK_MOUNT
}

# $1 = full path of created ramdisk
# $2 = user that will use ramisk
# $3 = mount point of created ramdisk
ramdisk_clean() {
    # Set user pemissions and empty out the disk.
    sleep 1 && chown -R $2 $1 2> /dev/null && sleep 1
    rm -rf $1 2> /dev/null

    # Save the mount point for unmounting later and make OSX happy.
    echo $3 > $1/.mount
    touch $1/.Trashes $1/.metadata_never_index
}

# $1 = path to move
# $2 = path to ramdisk
move_to_ram() {
    local dir_path="$2/$(dd if=/dev/random count=1 2>/dev/null | md5 | cut -c 1-4)/$(basename "$1")"
    mkdir -p "$dir_path"

    if [[ -d "$1" ]]; then
        mv "$1"/* "$dir_path" 2> /dev/null
        rm -rf "$1"
    fi

    ln -sf "$dir_path" "$1"
}

if [ $1 ] && [ $EUID -eq 0 ]; then
    ramdisk_check $RAMDISK_PATH $RAMDISK_NAME
    mount=$(ramdisk_mount $RAMDISK_NAME $RAMDISK_SIZE)
    ramdisk_clean $RAMDISK_PATH $RAMDISK_USER $mount

    for i in "${CACHE_PATHS[@]}"
    do
        echo "Moving to $RAMDISK_NAME: $i"
        move_to_ram "$i" $RAMDISK_PATH
    done
else
    echo "Pass username and/or run as root."
fi
