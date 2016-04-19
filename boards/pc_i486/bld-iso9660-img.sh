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

_distName="${TARGET_DIST_ISO_NAME}"

echo ""
echo "i> Creating CD-ROM ISO9660 image ..."
find cdrom -type d -exec chmod 755 {} \;
find cdrom -type f -exec chmod 755 {} \;
genisoimage							\
	-joliet							\
	-rational-rock						\
	-output ${_distName}					\
	-volid "${CONFIG_RELEASE_VERS} ${CONFIG_CPU_ARCH}"	\
	-eltorito-boot boot/isolinux/isolinux.bin		\
	-eltorito-catalog boot/isolinux/boot.cat		\
	-boot-info-table					\
	-boot-load-size 4					\
	-no-emul-boot						\
	cdrom
echo "... DONE"
echo ""
ls --color -hl ${_distName} | sed --expression="s|${TARGET_PROJ_DIR}/||"
echo "i> ISO image file $(basename ${_distName}) is ready."

unset _distName


# end of file
