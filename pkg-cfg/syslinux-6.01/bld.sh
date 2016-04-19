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

PKG_URL="http://www.kernel.org/pub/linux/utils/boot/syslinux/"
PKG_ZIP="syslinux-6.01.tar.xz"
PKG_SUM=""

PKG_TAR="syslinux-6.01.tar"
PKG_DIR="syslinux-6.01"


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
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

PKG_STATUS="install error"

cp "${PKG_DIR}/bios/extlinux/extlinux"                 extlinux
cp "${PKG_DIR}/bios/linux/syslinux"                    syslinux
cp "${PKG_DIR}/bios/core/isolinux.bin"                 isolinux.bin
cp "${PKG_DIR}/bios/com32/elflink/ldlinux/ldlinux.c32" ldlinux.c32

cp "${CROSSLINUX_LOADER_DIR}/"*.msg .
cp "${CROSSLINUX_LOADER_DIR}/"*.cfg .

for _f in *.msg; do
	if [[ -f "${_f}" ]]; then
		sed -i ${_f} -e "s?www\.crosslinux\.org?${CONFIG_BRAND_URL}?g"
	        chmod 644 "${_f}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
		sed -i ${_f} -e "s?crosslinux?${CONFIG_BRAND_NAME}?g"
	        chmod 644 "${_f}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
	fi
done

for _f in *.cfg; do
	if [[ -f "${_f}" ]]; then
		sed -i ${_f} -e "s?crosslinux?${CONFIG_BRAND_NAME}?g"
	        chmod 644 "${_f}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
	fi
done

echo "=> New files:"
ls --color -lh extlinux syslinux isolinux.bin ldlinux.c32 || true

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_clean
# ******************************************************************************

pkg_clean() {
PKG_STATUS=""
return 0
}


# end of file
