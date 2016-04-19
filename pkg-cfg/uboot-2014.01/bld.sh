#!/bin/${cl_bash}


# This file is part of the crosslinux software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2013-2013 Douglas Jerome <djerome@crosslinux.org>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA


# ******************************************************************************
# Definitions
# ******************************************************************************

PKG_URL="ftp://ftp.denx.de/pub/u-boot/"
PKG_ZIP="u-boot-2014.01.tar.bz2"
PKG_SUM=""

PKG_TAR="u-boot-2014.01.tar"
PKG_DIR="u-boot-2014.01"


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {

local patchDir="${CROSSLINUX_LOADER_DIR}/$1/patch"
local patchFile=""

PKG_STATUS="patch error"

cd "${PKG_DIR}"
for patchFile in "${patchDir}"/*; do
        [[ -r "${patchFile}" ]] && patch -p1 <"${patchFile}"
done
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {

PKG_STATUS="make error"

cd "${PKG_DIR}"

rm -f ../${CONFIG_UBOOT_TARGET}.MAKELOG

_oldPath=${PATH}
export PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}"
CROSS_COMPILE=${CONFIG_XTOOL_NAME}- ./MAKEALL ${CONFIG_UBOOT_TARGET}
export PATH=${_oldPath}
unset _oldPath

cp LOG/${CONFIG_UBOOT_TARGET}.MAKELOG ..

cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

PKG_STATUS="install error"

rm -rf MLO mlo u-boot.img mkimage

cd "${PKG_DIR}"
[[ -f MLO           ]] && cp MLO ..
[[ -f u-boot.img    ]] && cp u-boot.img ..
[[ -f tools/mkimage ]] && cp tools/mkimage ..
cd ..

PKG_STATUS=""
return 0

}


# *****************************************************************************
# Cleanup
# *****************************************************************************

pkg_clean() {
PKG_STATUS=""
return 0
}


# end of file
