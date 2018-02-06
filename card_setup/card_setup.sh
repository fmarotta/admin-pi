#!/usr/bin/sh

# Copyright 2018 Federico Marotta (C)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -o nounset
set -o errexit

SD_CARD='/dev/mmcblk0'
MOUNT_POINT='/mnt'
ARCH_LATEST='http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz'
SFDISK_SCRIPT='./raspi.fdisk'
FSTAB='./raspi.fstab'

function gecho
{
	# green
	COLOUR='\033[1;32m'
	DEFAULT='\033[0m'
	echo -e "${COLOUR}${1}${DEFAULT}"
}
function recho
{
	# red
	COLOUR='\033[1;31m'
	DEFAULT='\033[0m'
	echo -e "${COLOUR}${1}${DEFAULT}"
}

# For safety, unmount all the partitions first
gecho "Checking if the filesystems are already mounted..."
for p in `df | cut -d' ' -f1 | grep $SD_CARD`; do
	udisksctl unmount -b $p
done
gecho "Done."

# Use fdisk to load the previously generated partition table 
gecho "Partitioning SD card..."
cat << EOF | fdisk $SD_CARD || \
	(recho "Error while partitioning device with fdisk." && exit 1)
I
$SFDISK_SCRIPT
p
w
EOF
gecho "Done."

# Format the filesystems with mkfs and "turn on" the swap partition
# Say yes to proceeding in spite of there being another filesystem
gecho "Formatting filesystems..."
yes | mkfs -t vfat $SD_CARD"p1"
yes | mkfs -t ext4 $SD_CARD"p2"
yes | mkfs -t ext4 $SD_CARD"p5"
yes | mkfs -t ext4 $SD_CARD"p6"
yes | mkfs -t ext4 $SD_CARD"p7"
mkswap $SD_CARD"p3"
swapon $SD_CARD"p3"
gecho "Done."

# Mount the filesystems
gecho "Mounting filesystems..."
mkdir -p $MOUNT_POINT/root $MOUNT_POINT/boot $MOUNT_POINT/home \
	$MOUNT_POINT/local $MOUNT_POINT/var
mount $SD_CARD"p1" $MOUNT_POINT/boot
mount $SD_CARD"p2" $MOUNT_POINT/root
mount $SD_CARD"p5" $MOUNT_POINT/local
mount $SD_CARD"p6" $MOUNT_POINT/var
mount $SD_CARD"p7" $MOUNT_POINT/home
gecho "Done."

# Download Arch Linux ARM filesystem
gecho "Downloading latest Arch Linux ARM version..."
wget $ARCH_LATEST -O $MOUNT_POINT/ArchLinuxARM-rpi-2-latest.tar.gz
bsdtar -xvpf $MOUNT_POINT/ArchLinuxARM-rpi-2-latest.tar.gz \
	-C $MOUNT_POINT/root
sync

# Move the filesystems into the SD card's partitions
mv $MOUNT_POINT/root/boot/* $MOUNT_POINT/boot/
mv $MOUNT_POINT/root/usr/local/* $MOUNT_POINT/local/
mv $MOUNT_POINT/root/var/* $MOUNT_POINT/var/
mv $MOUNT_POINT/root/home/* $MOUNT_POINT/home/
gecho "Done."

# Import the correct fstab
gecho "Adding finishing touches..."
cp $FSTAB $MOUNT_POINT/root/etc/fstab

# Unmount everything
umount $MOUNT_POINT/root
umount $MOUNT_POINT/boot
umount $MOUNT_POINT/local
umount $MOUNT_POINT/var
umount $MOUNT_POINT/home

gecho "All set. Now insert the SD card into the raspberry pi and provide
power."
exit
