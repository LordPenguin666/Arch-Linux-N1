#!/bin/bash

MMC=$(lsblk -f|grep -o  mmcblk.|uniq)
BOOT_UUID=$(blkid -s UUID -o value /dev/${MMC}p1)
ROOTFS_UUID=$(blkid -s UUID -o value /dev/${MMC}p2)

#Resize Partition
cat > /fdisk.cmd <<-EOF
o
n
p
1
221184
1269760
t
c
n
p
2
1400832
15269887
p
w
EOF
fdisk /dev/$MMC < /fdisk.cmd
rm /fdisk.cmd

#Format Partition
mkfs.vfat -F 32 -n BOOT /dev/${MMC}p1
mkfs.ext4 -L ROOTFS /dev/${MMC}p2

MMC=$(lsblk -f|grep -o  mmcblk.|uniq)
BOOT_UUID=$(blkid -s UUID -o value /dev/${MMC}p1)
ROOTFS_UUID=$(blkid -s UUID -o value /dev/${MMC}p2)

#Mount Partition
mount /dev/${MMC}p2 /mnt
mkdir -p /mnt/boot
mount /dev/${MMC}p1 /mnt/boot

#Rsync Data To MMC
rsync -avPhHAX --numeric-ids  --delete --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/lost+found"} / /mnt

#Set UUID
sed -i "s/root=LABEL=ROOTFS/root=UUID=${ROOTFS_UUID}/" /mnt/boot/extlinux/extlinux.conf
sed -i "s/LABEL=ROOTFS/UUID=${ROOTFS_UUID}/" /mnt/etc/fstab
sed -i "s/LABEL=BOOT/UUID=${BOOT_UUID}/" /mnt/etc/fstab 

umount -R /mnt

exit 0

