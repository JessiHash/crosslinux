#!/bin/${cl_bash}


# This file is part of the crosslinux software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2013-2014 Douglas Jerome <djerome@crosslinux.org>
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

PKG_URL="http://lilo.alioth.debian.org/ftp/sources/"
PKG_ZIP="lilo-24.0.tar.gz"
PKG_SUM=""

PKG_TAR="lilo-24.0.tar"
PKG_DIR="lilo-24.0"


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {

local patchDir="${CROSSLINUX_PKGCFG_DIR}/$1/patch"
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

[[ "$(uname -m)" != "x86_64" ]] && HOST_CC="gcc"
[[ "$(uname -m)" == "x86_64" ]] && HOST_CC="gcc -m64"

source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	--jobs=${NJOBS} \
	BUILD_CC="${HOST_CC}" \
	CC="${CONFIG_XTOOL_NAME}-cc --sysroot=${TARGET_SYSROOT_DIR}" \
	CONFIG="-DBDATA         -DDSECS=3    -DDEVMAPPER=\"\" -DEVMS  \
		-DIGNORECASE    -DLVM        -DONE_SHOT       -DPASS160 \
		-DREWRITE_TABLE -DSOLO_CHAIN -DVERSION" \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	OPT="${CONFIG_CFLAGS}" \
	all || return 0
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"

cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

PKG_STATUS="install error"

cd "${PKG_DIR}"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
install --mode=755 --owner=0 --group=0 src/lilo "${TARGET_SYSROOT_DIR}/sbin"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"
cd ..

if [[ -d "rootfs/" ]]; then
	find "rootfs/" ! -type d -exec touch {} \;
	cp --archive --force rootfs/* "${TARGET_SYSROOT_DIR}"
fi

# ***** /etc/lilo.conf
#
_sedFile="${TARGET_SYSROOT_DIR}/etc/lilo.conf"
sed -i "${_sedFile}" -e "s/@BRAND_NAME@/${CONFIG_BRAND_NAME}/"
chmod 644 "${_sedFile}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
unset _sedFile

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
