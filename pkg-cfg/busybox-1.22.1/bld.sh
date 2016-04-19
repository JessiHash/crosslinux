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

PKG_URL="http://www.busybox.net/downloads/"
PKG_ZIP="busybox-1.22.1.tar.bz2"
PKG_SUM=""

PKG_TAR="busybox-1.22.1.tar"
PKG_DIR="busybox-1.22.1"


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
cp --archive "${PKG_DIR}" "${PKG_DIR}-suid"
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {

local cfgDir="${CROSSLINUX_PKGCFG_DIR}/$1"
local cfg=""
local SKIP_STRIP_FLAG=""

if [[ x"${CONFIG_SITE_SCRIPTS:-}" == x"" ]]; then
	SKIP_STRIP_FLAG=y
fi

source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"

CL_logcom "*****                 *****"
CL_logcom "***** Build - No SUID *****"
CL_logcom "*****                 *****"

cd "${PKG_DIR}"

cfg="${cfgDir}/_bbox-stnd.cfg"
if [[ -f "site/pkg-cfg-$1/_bbox-stnd.cfg" ]]; then
	cfg="site/pkg-cfg-$1/_bbox-stnd.cfg"
fi
cp "${cfg}" .config
if [[ x"${CONFIG_BUSYBOX_HAS_LOSETUP:-}" == x"" ]]; then
	sed -i ".config" -e 's/CONFIG_LOSETUP=y/# CONFIG_LOSETUP is not set/'
	chmod 644 ".config" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
else
	sed -i ".config" -e 's/# CONFIG_LOSETUP is not set/CONFIG_LOSETUP=y/'
	chmod 644 ".config" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
fi

PKG_STATUS="stnd make error"
CFLAGS="${CONFIG_CFLAGS} --sysroot=${TARGET_SYSROOT_DIR}" \
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	--jobs=${NJOBS} \
	ARCH=${CONFIG_CPU_ARCH} \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	CONFIG_PREFIX=${TARGET_SYSROOT_DIR} \
	SKIP_STRIP=${SKIP_STRIP_FLAG} \
	V=1 || return 0

cd ".."

CL_logcom "*****                               *****"
CL_logcom "***** Build and Install - With SUID *****"
CL_logcom "*****                               *****"

cd "${PKG_DIR}-suid"

cfg="${cfgDir}/_bbox-suid.cfg"
if [[ -f "site/pkg-cfg-$1/_bbox-suid.cfg" ]]; then
	cfg="site/pkg-cfg-$1/_bbox-suid.cfg"
fi
cp "${cfg}" .config

PKG_STATUS="suid make error"
CFLAGS="${CONFIG_CFLAGS} --sysroot=${TARGET_SYSROOT_DIR}" \
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	--jobs=${NJOBS} \
	ARCH=${CONFIG_CPU_ARCH} \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	CONFIG_PREFIX=${TARGET_SYSROOT_DIR} \
	SKIP_STRIP=${SKIP_STRIP_FLAG} \
	V=1 || return 0

cd ..

source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

PKG_STATUS="install error"

source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"

cd "${PKG_DIR}"
PKG_STATUS="make install error"
# CFLAGS, ARCH and CROSS_COMPILE seem to be needed to make install.
# Change the location of awk.
#
CFLAGS="${CONFIG_CFLAGS}  --sysroot=${TARGET_SYSROOT_DIR}" \
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	ARCH=${CONFIG_CPU_ARCH} \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	CONFIG_PREFIX=${TARGET_SYSROOT_DIR} \
	install || return 0
mv "${TARGET_SYSROOT_DIR}/usr/bin/awk" "${TARGET_SYSROOT_DIR}/bin/awk"
cd ..

cd "${PKG_DIR}-suid"
# Install busybox suid files.
#
rm --force "${TARGET_SYSROOT_DIR}/bin/busybox-suid"
rm --force "${TARGET_SYSROOT_DIR}/bin/mount"
rm --force "${TARGET_SYSROOT_DIR}/bin/ping"
rm --force "${TARGET_SYSROOT_DIR}/bin/su"
rm --force "${TARGET_SYSROOT_DIR}/bin/umount"
rm --force "${TARGET_SYSROOT_DIR}/usr/bin/crontab"
rm --force "${TARGET_SYSROOT_DIR}/usr/bin/passwd"
rm --force "${TARGET_SYSROOT_DIR}/usr/bin/traceroute"
_bbsuid="${TARGET_SYSROOT_DIR}/bin/busybox-suid"
install --mode=4711 --owner=0 --group=0 busybox "${_bbsuid}"
link "${_bbsuid}" "${TARGET_SYSROOT_DIR}/bin/mount"
link "${_bbsuid}" "${TARGET_SYSROOT_DIR}/bin/ping"
link "${_bbsuid}" "${TARGET_SYSROOT_DIR}/bin/su"
link "${_bbsuid}" "${TARGET_SYSROOT_DIR}/bin/umount"
link "${_bbsuid}" "${TARGET_SYSROOT_DIR}/usr/bin/crontab"
link "${_bbsuid}" "${TARGET_SYSROOT_DIR}/usr/bin/passwd"
link "${_bbsuid}" "${TARGET_SYSROOT_DIR}/usr/bin/traceroute"
unset _bbsuid
cd ..

source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"

if [[ -d "rootfs/" ]]; then
	find "rootfs/" ! -type d -exec touch {} \;
	cp --archive --force rootfs/* "${TARGET_SYSROOT_DIR}"
fi

declare _sedFile=""

# ***** /etc/HOSTNAME
#
_sedFile="${TARGET_SYSROOT_DIR}/etc/HOSTNAME"
sed -i "${_sedFile}" -e "s/@BRAND_NAME@/${CONFIG_BRAND_NAME}/"
chmod 644 "${_sedFile}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".

# ***** /etc/issue
#
for _sedFile in "${TARGET_SYSROOT_DIR}/etc/issue"*; do
	if [[ -f "${_sedFile}" ]]; then
		sed -i "${_sedFile}"					\
			-e "s/@BRAND_NAME@/${CONFIG_BRAND_NAME}/"	\
			-e "s/@RELEASE_VERS@/${CONFIG_RELEASE_VERS}/"	\
			-e "s/@RELEASE_NAME@/${CONFIG_RELEASE_NAME}/"	\
			-e "s/^.m/${CONFIG_CPU_ARCH}/"
		chmod 644 "${_sedFile}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
	fi
done

# ***** /etc/modprobe.d/modprobe.conf
# ***** /etc/modtab
#
case "${CONFIG_BOARD}" in
	'mac_g4')
		_sedFile="${TARGET_SYSROOT_DIR}/etc/modprobe.d/modprobe.conf"
		sed -i "${_sedFile}" -e "s/#nomac /# /"
		chmod 644 "${_sedFile}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
		_sedFile="${TARGET_SYSROOT_DIR}/etc/modtab"
		sed -i "${_sedFile}" -e "s/# snd-powermac/snd-powermac/"
		chmod 644 "${_sedFile}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
		;;
	*)
		_sedFile="${TARGET_SYSROOT_DIR}/etc/modprobe.d/modprobe.conf"
		sed -i "${_sedFile}" -e "s/#nomac //"
		chmod 644 "${_sedFile}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
		;;
esac

# ***** /etc/password
#
_sedFile="${TARGET_SYSROOT_DIR}/etc/passwd"
sed -i "${_sedFile}" -e "s/@BRAND_NAME@/${CONFIG_BRAND_NAME}/"
chmod 644 "${_sedFile}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".

# ***** /etc/rc.d/rc.sysinit
# ***** /etc/rc.d/rc.sysdone
#
_sedFile="${TARGET_SYSROOT_DIR}/etc/rc.d/rc.sysinit"
sed -i "${_sedFile}"					\
	-e "s/@BRAND_NAME@/${CONFIG_BRAND_NAME}/"	\
	-e "s|@BRAND_URL@|${CONFIG_BRAND_URL}|"		\
	-e "s/@RELEASE_VERS@/${CONFIG_RELEASE_VERS}/"
chmod 775 "${_sedFile}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".
_sedFile="${TARGET_SYSROOT_DIR}/etc/rc.d/rc.sysdone"
sed -i "${_sedFile}"					\
	-e "s/@BRAND_NAME@/${CONFIG_BRAND_NAME}/"	\
	-e "s/@RELEASE_VERS@/${CONFIG_RELEASE_VERS}/"
chmod 775 "${_sedFile}" # Code Issue [02] -- See "A2_Known_Issues_And_Problems.txt".

unset _sedFile

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_clean
# ******************************************************************************

pkg_clean() {
rm --force --recursive "${PKG_DIR}-suid"
PKG_STATUS=""
return 0
}


# end of file
