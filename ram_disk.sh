#!/bin/sh

echo "Creating 2GB ramdisk..."
diskutil erasevolume HFS+ 'RAM Disk' `hdiutil attach -nomount ram://4194304`

echo "Moving Chrome cache to to ramdisk and symlinking it back..."
mv  ~/Library/caches/Google/Chrome/default/cache "/Volumes/RAM Disk/cache"
ln -s "/Volumes/RAM Disk/cache" ~/Library/caches/Google/Chrome/default/cache

echo "Moving Safari cache to to ramdisk and symlinking it back..."
mv  ~/Library/Caches/com.apple.Safari "/Volumes/RAM Disk/com.apple.Safari"
ln -s "/Volumes/RAM Disk/com.apple.Safari" ~/Library/Caches/com.apple.Safari

echo "Done!"

