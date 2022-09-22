#!/bin/bash
# Script to download squashfs-tools v4.3, apply the patches, perform a clean build, and install.

SQFS_VER=4.3

# If not root, perform 'make install' with sudo
SUDO=""
[ "$EUID" -ne 0 ] && SUDO="sudo"

# Install prerequisites
if hash apt-get &>/dev/null
then
    $SUDO apt-get install build-essential liblzma-dev liblzo2-dev zlib1g-dev
fi

# Make sure we're working in the same directory as the build.sh script
cd "$(dirname "$(readlink  -f "$0")")" || exit

# Download squashfs${SQFS_VER}.tar.gz if it does not already exist
if [ ! -e squashfs${SQFS_VER}.tar.gz ]
then
    wget -c https://downloads.sourceforge.net/project/squashfs/squashfs/squashfs${SQFS_VER}/squashfs${SQFS_VER}.tar.gz
fi

# Remove any previous squashfs4.3 directory to ensure a clean patch/build
rm -rf squashfs${SQFS_VER}

echo_c 33 "\nExtracting bundle"
# Extract squashfs${SQFS_VER}.tar.gz
tar -zxvf squashfs${SQFS_VER}.tar.gz

echo_c 33 "\nPatching files"
# Patch, build, and install the source
cd squashfs${SQFS_VER} || exit

# patch -p0 < ../patches/patch0.txt
# find ../patches/ -name "*.patch" -print0 | xargs -0 patch -p2
for i in ../patches/*.patch; do patch -p0 <"$i"; done

cd squashfs-tools || exit

make EXTRA_CFLAGS=-fcommon && $SUDO make install
