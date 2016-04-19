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

PKG_URL="http://sourceforge.net/projects/calc/files/calc/2.12.4.13/"
PKG_ZIP="calc-2.12.4.13.tar.bz2"
PKG_SUM=""

PKG_TAR="calc-2.12.4.13.tar"
PKG_DIR="calc-2.12.4.13"


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

local BS_BITS="32"

PKG_STATUS="make error"

if [[ "${CONFIG_CPU_ARCH}" == "x86_64" ]]; then BS_BITS=64; fi

cd "${PKG_DIR}"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
NJOBS=1 # Seems like this version of calc can't parallel make.
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make clobber
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	--jobs=${NJOBS} \
	AR="${CONFIG_XTOOL_NAME}-ar" \
	AS="${CONFIG_XTOOL_NAME}-as --sysroot=${TARGET_SYSROOT_DIR}" \
	CC="${CONFIG_XTOOL_NAME}-cc --sysroot=${TARGET_SYSROOT_DIR}" \
	CXX="${CONFIG_XTOOL_NAME}-c++ --sysroot=${TARGET_SYSROOT_DIR}" \
	LD="${CONFIG_XTOOL_NAME}-ld --sysroot=${TARGET_SYSROOT_DIR}" \
	NM="${CONFIG_XTOOL_NAME}-nm" \
	OBJCOPY="${CONFIG_XTOOL_NAME}-objcopy" \
	RANLIB="${CONFIG_XTOOL_NAME}-ranlib" \
	SIZE="${CONFIG_XTOOL_NAME}-size" \
	STRIP="${CONFIG_XTOOL_NAME}-strip" \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	calc-static-only \
		BLD_TYPE=calc-static-only \
		LONG_BITS=${BS_BITS} || return 0
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
instCmd="install --owner=root --group=root"
${instCmd} --mode=755 calc-static  "${TARGET_SYSROOT_DIR}/usr/bin/calc"
${instCmd} --mode=755 --directory  "${TARGET_SYSROOT_DIR}/usr/share/calc/"
${instCmd} --mode=755 cal/bindings "${TARGET_SYSROOT_DIR}/usr/share/calc/"
unset instCmd
cd ..

if [[ -d "rootfs/" ]]; then
	find "rootfs/" ! -type d -exec touch {} \;
	cp --archive --force rootfs/* "${TARGET_SYSROOT_DIR}"
fi

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
