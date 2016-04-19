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


# *****************************************************************************
# Main Program
# *****************************************************************************

echo -n "i> Making target/mnt directory ....................... "
rm --force --recursive mnt
mkdir mnt
echo "DONE"

echo -n "i> Gathering boot files .............................. "
cp ${TARGET_LOADER_DIR}/MLO          sdcard/boot/MLO
cp ${TARGET_LOADER_DIR}/u-boot.img   sdcard/boot/u-boot.img
cp kroot/boot/am335x-bone.dtb        sdcard/boot/am335x-bone.dtb
cp kroot/boot/uImage                 sdcard/boot/uImage
cp ${CROSSLINUX_BOARDC_DIR}/uEnv.txt sdcard/boot/uEnv.txt
if [[ x"${CONFIG_INCLUDE_MEDIA_DEBUG_KERNEL:-}" == x"y" ]]; then
	cp kroot/boot/System.map sdcard/boot/System.map
	cp kroot/boot/vmlinux    sdcard/boot/vmlinux
fi
chmod 644 sdcard/boot/*
chmod 755 sdcard/boot/vmlinux
echo "DONE"


# end of file
