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

PKG_URL="http://www.kernel.org/pub/linux/utils/util-linux/v2.24/"
PKG_ZIP="util-linux-2.24.1.tar.gz"
PKG_SUM=""

PKG_TAR="util-linux-2.24.1.tar"
PKG_DIR="util-linux-2.24.1"


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

PKG_STATUS="./configure error"

# The FHS recommends using the /var/lib/hwclock directory instead of the usual
# /etc directory as the location for the adjtime file.  To make the hwclock
# program FHS-compliant, run the following:
# sed -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
#       -i $(grep -rl '/etc/adjtime' .)
# mkdir -pv /var/lib/hwclock

#  --disable-libuuid       do not build libuuid and uuid utilities
#  --disable-uuidd         do not build the uuid daemon
#  --disable-libblkid      do not build libblkid and blkid utilities
#  --disable-libmount      do not build libmount

# freak-ass magic from https://lkml.org/lkml/2012/2/24/337
# => scanf_cv_alloc_modifier=as  GNU extension to alloc mem for string [evil]
# => scanf_cv_alloc_modifier=ms  POSIX way to alloc mem for string
# => scanf_cv_alloc_modifier=no  maybe: do not alloc mem for string?

cd "${PKG_DIR}"

source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" \
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
CFLAGS="${CONFIG_CFLAGS}" \
scanf_cv_alloc_modifier=ms \
./configure \
	--build=${MACHTYPE} \
	--host=${CONFIG_XTOOL_NAME} \
	--disable-agetty \
	--disable-bfs \
	--disable-cramfs \
	--disable-cytune \
	--disable-eject \
	--disable-fallocate \
	--disable-fdformat \
	--disable-fsck \
	--disable-hwclock \
	--disable-kill \
	--disable-last \
	--disable-libmount \
	--disable-libuuid \
	--disable-login \
	--disable-mesg \
	--disable-more \
	--disable-mount \
	--disable-mountpoint \
	--disable-nologin \
	--disable-nsenter \
	--disable-partx \
	--disable-pg \
	--disable-pivot_root \
	--disable-raw \
	--disable-rename \
	--disable-runuser \
	--disable-schedutils \
	--disable-setpriv \
	--disable-setterm \
	--disable-su \
	--disable-sulogin \
	--disable-switch_root \
	--disable-ul \
	--disable-unshare \
	--disable-utmpdump \
	--disable-uuidd \
	--disable-wall \
	--disable-wdctl \
	--disable-makeinstall-chown \
	--disable-makeinstall-setuid \
	--without-ncurses || return 0
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"

cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {

PKG_STATUS="make error"

cd "${PKG_DIR}"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	--jobs=${NJOBS} \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- || return 0
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

_stageDir="${TARGET_PROJ_DIR}/build/$1"
mkdir "${_stageDir}"

PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	DESTDIR=${_stageDir} \
	install || return 0

_dest="${TARGET_SYSROOT_DIR}"
install --directory --mode=755 --group=0 --owner=0 ${_dest}/usr/include/blkid/
install --directory --mode=755 --group=0 --owner=0 ${_dest}/usr/lib/pkgconfig/
instDat="install --mode=644 --group=0 --owner=0"
instExe="install --mode=755 --group=0 --owner=0"
${instExe} ${_stageDir}/lib/libblkid.so.1.1.0      ${_dest}/lib/
${instExe} ${_stageDir}/sbin/blkid                 ${_dest}/sbin/
${instExe} ${_stageDir}/sbin/findfs                ${_dest}/sbin/
${instExe} ${_stageDir}/sbin/losetup               ${_dest}/sbin/
${instDat} ${_stageDir}/usr/include/blkid/blkid.h  ${_dest}/usr/include/blkid/
${instDat} ${_stageDir}/usr/lib/libblkid.a         ${_dest}/usr/lib/
${instDat} ${_stageDir}/usr/lib/pkgconfig/blkid.pc ${_dest}/usr/lib/pkgconfig/
ln --force --symbolic libblkid.so.1.1.0           ${_dest}/lib/libblkid.so.1
ln --force --symbolic ../../lib/libblkid.so.1.1.0 ${_dest}/usr/lib/libblkid.so
unset instDat
unset instExe
unset _dest

rm --force --recursive ${_stageDir}
unset _stageDir

source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"
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
