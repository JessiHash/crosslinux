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


# *****************************************************************************
# Main Program
# *****************************************************************************

echo -n "i> Gathering boot files .............................. "
_dest="cdrom/boot/isolinux"
cp "${TARGET_LOADER_DIR}/isolinux.bin" "${_dest}/isolinux.bin"
cp "${TARGET_LOADER_DIR}/isolinux.cfg" "${_dest}/isolinux.cfg"
cp "${TARGET_LOADER_DIR}/ldlinux.c32"  "${_dest}/ldlinux.c32"
for _f in ${TARGET_LOADER_DIR}/*.msg; do
	if [[ -f "${_f}" ]]; then cp "${_f}" "${_dest}/"; fi
done; unset _f
unset _dest
chmod 644 cdrom/boot/isolinux/*
if [[ x"${CONFIG_ROOTFS_INITRD:-}" == x"y" ]]; then
	cp ${TARGET_ROOT_IRD_NAME} cdrom/boot/filesys
	chmod 644 cdrom/boot/filesys
fi
if [[ x"${CONFIG_ROOTFS_INITRAMFS:-}" == x"y" ]]; then
	cp ${TARGET_ROOT_IFS_NAME} cdrom/boot/filesys
	chmod 644 cdrom/boot/filesys
fi
if [[ x"${CONFIG_INCLUDE_MEDIA_DEBUG_KERNEL:-}" == x"y" ]]; then
	cp kroot/boot/System.map cdrom/boot/System.map
	cp kroot/boot/vmlinux    cdrom/boot/vmlinux
	chmod 644 cdrom/boot/System.map
	chmod 755 cdrom/boot/vmlinux
fi
cp kroot/boot/bzImage cdrom/boot/vmlinuz
chmod 644 cdrom/boot/vmlinuz
echo "DONE"

echo -n "i> Compress the root file system initrd .............. "
gzip --no-name cdrom/boot/filesys
echo "DONE"

echo -n "i> Set the initrd file system size ................... "
_rdSize=$((${CONFIG_ROOTFS_SIZE_MB}*1024))
sed --in-place \
	--expression="s/root=/ramdisk_size=${_rdSize} root=/" \
	cdrom/boot/isolinux/isolinux.cfg
unset _rdSize
echo "DONE"

echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cat cdrom/boot/isolinux/isolinux.cfg
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

return 0


# end of file
