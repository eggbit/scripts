#!/bin/sh

SAFARI_CACHE_DIR=~/Library/Caches/com.apple.Safari
CHROME_CACHE_DIR=~/Library/caches/Google/Chrome/default/cache
SPOTIFY_CACHE_DIR=~/Library/caches/com.spotify.client
RAMDISK_NAME="RAM Disk"
RAMDISK_SIZE=4194304 # megabytes_you_want * 2048

# $1 = path to move
move_to_ram() {
    if [[ -d "$1" ]]; then
        mv $1 "/Volumes/$RAMDISK_NAME/$(basename $1)"
    else
        mkdir "/Volumes/$RAMDISK_NAME/$(basename $1)"
    fi

    ln -s "/Volumes/$RAMDISK_NAME/$(basename $1)" $1
}

echo "Creating 2GB ramdisk..."
diskutil erasevolume HFS+ "$RAMDISK_NAME" `hdiutil attach -nomount ram://$RAMDISK_SIZE`

echo "Moving Safari cache to ramdisk..."
move_to_ram $SAFARI_CACHE_DIR

echo "Moving Chrome cache to ramdisk..."
move_to_ram $CHROME_CACHE_DIR

echo "Moving Spotify cache to ramdisk..."
move_to_ram $SPOTIFY_CACHE_DIR

echo "Done!"

