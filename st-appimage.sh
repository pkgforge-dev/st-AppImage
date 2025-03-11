#!/bin/sh

# alpine deps: ncurses-terminfo-base font-liberation build-base
# ncurses-terminfo-base font-liberation fontconfig-dev freetype-dev
# libx11-dev libxext-dev libxft-dev xvfb-run git patchelf binutils

set -eux

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1

UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
SHARUN="https://github.com/VHSgunzo/sharun/releases/latest/download/sharun-$ARCH"
APPIMAGETOOL="https://github.com/pkgforge-dev/appimagetool-uruntime/releases/download/continuous/appimagetool-$ARCH.AppImage"

# Prepare AppDir
mkdir -p ./AppDir
cd ./AppDir

# make st
git clone https://git.suckless.org/st ./st
( cd ./st && make install PREFIX=../shared )
rm -rf ./st

echo '[Desktop Entry]
Name=st
Comment=st is a simple virtual terminal emulator for X which sucks less
Exec=st
Terminal=false
Type=Application
Icon=st
Categories=System;TerminalEmulator;' > st.desktop

touch ./st.png

# ADD LIBRARIES
wget "$SHARUN" -O ./sharun
wget "$LIB4BN" -O ./lib4bin
chmod +x ./lib4bin ./sharun
xvfb-run -a -- ./lib4bin -p -v -e -s -k ./shared/bin/st

# Prepare sharun
echo "Preparing sharun..."
ln -s ./bin/st ./AppRun
./sharun -g

export VERSION=$(./AppRun -v 2>&1 | awk '{print $2}')
echo "$VERSION" > ~/version

# make appimage
cd ..
wget -q "$APPIMAGETOOL" -O ./appimagetool
chmod +x ./appimagetool
./appimagetool -n -u "$UPINFO" "$PWD"/AppDir "$PWD"/st-"$VERSION"-anylinux-"$ARCH".AppImage
echo "All Done!"
