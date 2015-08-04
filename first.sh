#!/bin/bash

# Ask for password and keep-alive for duration of the script
# Taken from https://gist.github.com/brandonb927/3195465
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Install Homebrew..."
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Make sure everything is fine..."
brew doctor || exit 1

echo "Install Cask..."
brew install caskroom/cask/brew-cask

echo "Enable multiple cask versions..."
brew tap caskroom/versions

echo "Software..."
brew install git
brew install python
brew install node
brew install zsh
brew install wget
brew install tree
brew install rbenv --HEAD
brew install ruby-build

brew cask install firefoxdeveloperedition
brew cask install google-chrome-dev
brew cask install dropbox
brew cask install bettertouchtool
brew cask install macpass
brew cask install spotify
brew cask install iterm2
brew cask install virtualbox
brew cask install vagrant
brew cask install google-drive
brew cask install sublime-text3
brew cask install twitterrific

echo "Creating subl symlink..."
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl

echo "Node..."
npm install -g jshint

# Set up zsh seperately.

