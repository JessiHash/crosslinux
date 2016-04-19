#!/bin/${cl_bash}


# This file is part of the crosslinux software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2014-2014 Douglas Jerome <djerome@crosslinux.org>
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

PKG_URL="(cross-tools)"
PKG_ZIP="(none)"
PKG_SUM=""

PKG_TAR="(none)"
PKG_DIR="(none)"


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {
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

local ctsysroot="" # cross-tool chain sysroot
local dir="${TARGET_SITE_DIR}/pkg-cfg-$1"
local fileList="${dir}/files-${CONFIG_CPU_ARCH}"

PKG_STATUS="make error"

mkdir --parents "${dir}"
rm --force "${fileList}"

ctsysroot=$("${CONFIG_XTOOL_BIN_DIR}/${CONFIG_XTOOL_NAME}-cc" -print-sysroot)

find "${ctsysroot}/usr/include" -type f | sort >"${fileList}"
sed --expression="s#${ctsysroot}/##"   --in-place "${fileList}"
sed --expression="/\.install/d"        --in-place "${fileList}"
sed --expression="/\.\.install\.cmd/d" --in-place "${fileList}"
echo "usr/lib/Scrt1.o"                >>"${fileList}"
echo "usr/lib/crt1.o"                 >>"${fileList}"
echo "usr/lib/crti.o"                 >>"${fileList}"
echo "usr/lib/crtn.o"                 >>"${fileList}"
echo "usr/lib/libc_nonshared.a"       >>"${fileList}"
echo "usr/lib/libpthread_nonshared.a" >>"${fileList}"
chmod 666 "${fileList}"

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

local dir="${TARGET_SITE_DIR}/pkg-cfg-$1"
local fileList="${dir}/files-${CONFIG_CPU_ARCH}"

PKG_STATUS="instal error"

while read fname pad; do
	fname="${TARGET_SYSROOT_DIR}/${fname}"
	[[ "${fname:0:1}" == "#" ]] && continue || true
	[[ -e "${fname}"         ]] && touch "${fname}"
done <${fileList}

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
