#!/bin/bash

#Create Image
fallocate -l 2G /Arch-N1.img

#Resize Image
cat > /fdisk.cmd <<-EOF
o
n
p
1
 
+512MB
t
c
n
p
2
 
 
w
EOF
fdisk /Arch-N1.img < /fdisk.cmd
rm /fdisk.cmd

#Mount As Loop Device
losetup -f -P --show /Arch-N1.img
sleep 5

#Mount And Format Partition
mkfs.vfat -F 32 -n "BOOT" /dev/loop0p1
mke2fs -F -q -t ext4 -L ROOTFS -m 0 /dev/loop0p2
mkdir -p /img
mount /dev/loop0p2 /img
mkdir -p /img/boot
mount /dev/loop0p1 /img/boot

#Backup
cd /
DIR_INSTALL=/img
cp -r /boot/* /img/boot/
mkdir -p $DIR_INSTALL/dev
mkdir -p $DIR_INSTALL/media
mkdir -p $DIR_INSTALL/mnt
mkdir -p $DIR_INSTALL/proc
mkdir -p $DIR_INSTALL/run
mkdir -p $DIR_INSTALL/sys
mkdir -p $DIR_INSTALL/tmp
 
tar -cvf - bin | (cd $DIR_INSTALL; tar -xpvf -)
tar -cvf - boot | (cd $DIR_INSTALL; tar -xpvf -)
tar -cvf - etc | (cd $DIR_INSTALL; tar -xpvf -)
tar -cvf - home | (cd $DIR_INSTALL; tar -xpvf -)
tar -cvf - lib | (cd $DIR_INSTALL; tar -xpvf -)
tar -cvf - opt | (cd $DIR_INSTALL; tar -xpvf -)
tar -cvf - root | (cd $DIR_INSTALL; tar -xpvf -)
tar -cvf - sbin | (cd $DIR_INSTALL; tar -xpvf -)
tar -cvf - srv | (cd $DIR_INSTALL; tar -xpvf -)
tar -cvf - usr | (cd $DIR_INSTALL; tar -xpvf -)
tar -cvf - var | (cd $DIR_INSTALL; tar -xpvf -)

sync

umount -R /img

exit 0
