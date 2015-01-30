#/bin/bash

# Based on this: https://gist.github.com/brandonb927/3195465

echo ""
echo "Setting up sane OSX Yosemite defaults..."

# Ask for password and keep-alive for duration of the script
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

printf "Computer name: "
read -r response

echo "Setting computer name..."
sudo scutil --set ComputerName $response
sudo scutil --set HostName $response
sudo scutil --set LocalHostName $response
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $response

echo "Setting noatime on SSD..."
sudo cp com.nullvision.noatime.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/com.nullvision.noatime.plist
sudo chmod 644 /Library/LaunchDaemons/com.nullvision.noatime.plist
sudo launchctl load -w /Library/LaunchDaemons/com.nullvision.noatime.plist

echo "Hiding the Spotlight icon..."
sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

echo "Disabling Spotlight indexing for any volume that gets mounted and has not yet been indexed before..."
echo 'Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.'
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

echo "Changing Spotlight indexing order..."
defaults write com.apple.spotlight orderedItems -array \
  '{"enabled" = 1;"name" = "APPLICATIONS";}' \
  '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
  '{"enabled" = 1;"name" = "DIRECTORIES";}' \
  '{"enabled" = 1;"name" = "PDF";}' \
  '{"enabled" = 1;"name" = "FONTS";}' \
  '{"enabled" = 0;"name" = "DOCUMENTS";}' \
  '{"enabled" = 0;"name" = "MESSAGES";}' \
  '{"enabled" = 0;"name" = "CONTACT";}' \
  '{"enabled" = 0;"name" = "EVENT_TODO";}' \
  '{"enabled" = 0;"name" = "IMAGES";}' \
  '{"enabled" = 0;"name" = "BOOKMARKS";}' \
  '{"enabled" = 0;"name" = "MUSIC";}' \
  '{"enabled" = 0;"name" = "MOVIES";}' \
  '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
  '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
  '{"enabled" = 0;"name" = "SOURCE";}' \
  '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
  '{"enabled" = 0;"name" = "MENU_OTHER";}' \
  '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
  '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
  '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
  '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

# Load new settings before rebuilding the index
killall mds > /dev/null 2>&1

# Make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null

# Rebuild the index from scratch
sudo mdutil -E / > /dev/null


echo "Expanding the save panel by default..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Automatically quit printer app once the print jobs complete..."
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "Saving to disk, rather than iCloud, by default..."
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window..."
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

echo "Check for software updates daily, not just once per week..."
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo "Removing duplicates in the 'Open With' menu..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo "Disabling smart quotes and smart dashes..."
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "Disabling hibernation..."
sudo pmset -a hibernatemode 0

echo "Removing sleep image file..."
sudo rm /Private/var/vm/sleepimage
sudo touch /Private/var/vm/sleepimage
sudo chflags uchg /Private/var/vm/sleepimage

echo "Disabling the sudden motion sensor..."
sudo pmset -a sms 0

echo "Disabling system-wide resume..."
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

echo "Disabling menu bar transparency...."
defaults write com.apple.universalaccess reduceTransparency -bool true

echo "Speeding up wake from sleep to 24 hours from an hour..."
# http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
sudo pmset -a standbydelay 86400

echo "Increasing sound quality for Bluetooth headphones/headsets..."
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

echo "Enabling full keyboard access for all controls (enable Tab in modal dialogs, menu windows, etc.)..."
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo "Disabling press-and-hold for special keys in favor of key repeat..."
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo "Setting a blazingly fast keyboard repeat rate..."
defaults write NSGlobalDomain KeyRepeat -int 0

# echo "Disabling auto-correct..."
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "Setting trackpad & mouse speed to a reasonable number..."
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

echo "Turn off keyboard illumination when computer is not used for 5 minutes..."
defaults write com.apple.BezelServices kDimTime -int 300

# echo "Disabling automatic brightness adjustment..."
# sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false

# echo "Disabling automatic keyboard backlight adjustment...""
# sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Keyboard Enabled" -bool false

echo "Requiring password immediately after sleep or screen saver begins..."
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "Save screenshots to Desktop..."
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

echo "Setting screenshot format to PNG..."
defaults write com.apple.screencapture type -string "png"

echo "Enabling subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# echo "Enabling HiDPI display modes (requires restart)"
# sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

echo "Showing icons for hard drives, servers, and removable media on the desktop..."
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

# echo "Showing hidden files in Finder by default..."
# defaults write com.apple.Finder AppleShowAllFiles -bool true

# echo "Showing dotfiles in Finder by default..."
# defaults write com.apple.finder AppleShowAllFiles TRUE

echo "Showing all filename extensions in Finder by default..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Showing status bar in Finder by default..."
defaults write com.apple.finder ShowStatusBar -bool true

echo "Displaying full POSIX path as Finder window title..."
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# echo "Disabling the warning when changing a file extension...""
# defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Using list view in all Finder windows by default..."
defaults write com.apple.finder FXPreferredViewStyle Nlsv

echo "Avoiding creation of .DS_Store files on network volumes..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "Disabling disk image verification..."
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

echo "Allowing text selection in Quick Look/Preview in Finder by default..."
defaults write com.apple.finder QLEnableTextSelection -bool true

echo "Enabling snap-to-grid for icons on the desktop and in other icon views..."
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# echo "Wiping all (default) app icons from the Dock..."
# defaults write com.apple.dock persistent-apps -array

echo "Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate..."
defaults write com.apple.dock tilesize -int 36

echo "Speeding up Mission Control animations and grouping windows by application..."
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

echo "Setting Dock to auto-hide and removing the auto-hiding delay..."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

echo "Privacy: Don't send search queries to Apple..."
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

echo "Hiding Safari's bookmarks bar by default..."
defaults write com.apple.Safari ShowFavoritesBar -bool false

echo "Hiding Safari's sidebar in Top Sites..."
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

echo "Disabling Safari's thumbnail cache for History and Top Sites..."
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

echo "Enabling Safari's debug menu..."
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

echo "Making Safari's search banners default to Contains instead of Starts With..."
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

echo "Removing useless icons from Safari's bookmarks bar..."
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

echo "Enabling the Develop menu and the Web Inspector in Safari..."
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

echo "Adding a context menu item for showing the Web Inspector in web views..."
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

echo "Disabling the annoying backswipe in Chrome..."
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

echo "Using the system-native print preview dialog in Chrome..."
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

echo "Setting email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app..."
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

echo "Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default..."
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

echo "Preventing Time Machine from prompting to use new hard drives as backup volume..."
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo "Disabling local Time Machine backups?..."
hash tmutil &> /dev/null && sudo tmutil disablelocal

echo "Disabling automatic emoji substitution in Messages.app..."
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

echo "Disabling smart quotes in Messages.app..."
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

# echo "Disabling continuous spell checking in Messages.app...""
# defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

# echo "Linking Sublime Text for command line usage as subl"
# ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl

echo "Setting Sublime Text 3 as default git editor..."
git config --global core.editor "subl -n -w"

echo ""
echo "Done!"
echo ""
echo ""
echo "################################################################################"
echo ""
echo ""
echo "Note that some of these changes require a logout/restart to take effect."
echo "Killing some open applications in order to take effect."
echo ""

find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer" \
  "Terminal" "Transmission"; do
  killall "${app}" > /dev/null 2>&1
done

