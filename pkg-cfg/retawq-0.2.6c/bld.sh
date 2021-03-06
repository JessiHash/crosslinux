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

PKG_URL="http://sourceforge.net/projects/retawq/files/retawq/retawq-0.2.6c/"
PKG_ZIP="retawq-0.2.6c.tar.gz"
PKG_SUM=""

PKG_TAR="retawq-0.2.6c.tar"
PKG_DIR="retawq-0.2.6c"


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

local THREADING=1

PKG_STATUS="make error"

if [[ x"${RETAWQ_HAS_THREADING:-}" == x"y" ]]; then
	THREADING=0
fi

cd "${PKG_DIR}"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	CC="${CONFIG_XTOOL_NAME}-cc --sysroot=${TARGET_SYSROOT_DIR}" \
	CFLAGS="${CONFIG_CFLAGS}" \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	OPTION_NEWS=0 \
	OPTION_TEXTMODEMOUSE=0 \
	OPTION_TG=bicurses \
	OPTION_THREADING=${THREADING} \
	devel || return 0
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
install --mode=755 --owner=0 --group=0 retawq "${TARGET_SYSROOT_DIR}/usr/bin"
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
