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

PKG_URL="http://ftp.gnu.org/gnu/gcc/gcc-4.7.3/ ftp://sourceware.org/pub/gcc/releases/gcc-4.7.3/"
PKG_ZIP="gcc-4.7.3.tar.bz2"
PKG_SUM=""

PKG_TAR="gcc-4.7.3.tar"
PKG_DIR="gcc-4.7.3"


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

if [[ "${CONFIG_CPU_ARCH}" = "x86_64" ]]; then
	# Pure 64-bit fixups:  On x86_64, unsetting the multilib spec for GCC
	# ensures that it won't attempt to link against libraries on the host.
	for file in $(find gcc/config -name t-linux64) ; do
		sed -e '/MULTILIB_OSDIRNAMES/d' -i "${file}"
	done
	unset file
fi

cd ..

rm --force --recursive "build-gcc"
mkdir "build-gcc"

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {

local HARD_FLOAT_SPEC=""
local WITH_FLOAT=""

# This is a very non-standard configuration; it works because of the crosslinux
# patch.  The '--with-build-sysroot=' option is not correctly used herein.  The
# crosslinux patch allows this abnormal '--with-build-sysroot=' usage to set a
# build-time configure-time reference to the target system header files so that
# the gcc configure script does not look in the host build system's header files
# to determine the target system's capabilities.

PKG_STATUS="./configure error"

cd "build-gcc"

if [[ "${CONFIG_CPU_ARCH}" = "armv7" ]]; then
	# cortex-a8 fixups:  need to specify to use hard float.
	HARD_FLOAT_SPEC="-mfloat-abi=hard"
	WITH_FLOAT="--with-float=hard"
fi

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
CFLAGS="${HARD_FLOAT_SPEC} ${CONFIG_CFLAGS}" \
../${PKG_DIR}/configure \
	--build=${MACHTYPE} \
	--host=${CONFIG_XTOOL_NAME} \
	--target=${CONFIG_XTOOL_NAME} \
	--prefix=/usr \
	--infodir=/usr/share/info \
	--mandir=/usr/share/man \
	--enable-languages=c,c++ \
	--enable-c99 \
	--enable-clocale=gnu \
	--enable-cloog-backend=isl \
	--enable-long-long \
	--enable-shared \
	--enable-symvers=gnu \
	--enable-threads=posix \
	--enable-__cxa_atexit \
	--disable-bootstrap \
	--disable-libada \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--disable-lto \
	--disable-multilib \
	--disable-nls \
	--with-build-sysroot=${TARGET_SYSROOT_DIR} \
	${WITH_FLOAT} \
	--with-libelf=no \
	--with-cloog=${TARGET_SYSROOT_DIR}/usr \
	--with-gmp=${TARGET_SYSROOT_DIR}/usr \
	--with-mpc=${TARGET_SYSROOT_DIR}/usr \
	--with-mpfr=${TARGET_SYSROOT_DIR}/usr \
	--with-ppl=${TARGET_SYSROOT_DIR}/usr || return 0
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

cd "build-gcc"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
NJOBS=1
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

cd "build-gcc"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	DESTDIR=${TARGET_SYSROOT_DIR} \
	install || return 0
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
rm --force --recursive "build-gcc"
return 0
}


# end of file
