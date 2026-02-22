#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q st | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/702499f331aa9c38309e1af99de4021013916297/Papirus/64x64/apps/st.svg
export DEPLOY_OPENGL=0
export DEPLOY_VULKAN=0

# Deploy dependencies
quick-sharun /usr/bin/st

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
quick-sharun --test ./dist/*.AppImage
