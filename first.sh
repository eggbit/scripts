#!/bin/bash

# Install xcode tools
xcode-select --install

# Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Make sure everything is fine
brew doctor || exit 1

# Install Cask
brew install caskroom/cask/brew-cask

# Enable multiple cask versions
brew tap caskroom/versions

# Software
brew install git
brew install python
brew install node
brew install zsh

brew cask install firefoxdeveloperedition
brew cask install google-chrome-dev
brew cask install dropbox
brew cask install bettertouchtool
brew cask install macpass
brew cask install spotify
brew cask install iterm2
brew cask install virtualbox
brew cask install google-drive
brew cask install sublime-text3

echo "Creating subl symlink..."
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl

brew cask install twitterrific

# Set up zsh seperately.

