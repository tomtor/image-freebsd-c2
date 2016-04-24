#!/bin/sh

# Inspired by the RPI3 and Odroid C1 image build scripts

FIRMWAREDIR=$PWD

# Set this based on how many CPUs you have
JFLAG=-j2

# Where to put your build objects, you need write access
export MAKEOBJDIRPREFIX=${HOME}/obj

# Where to install to
DEST=${MAKEOBJDIRPREFIX}/c2
DEST2=/media/swan/tom

set -e

cd /usr/src

#make TARGET=arm64 -s ${JFLAG} buildworld NO_CLEAN=YES
make TARGET=arm64 -s ${JFLAG} buildkernel NO_CLEAN=YES KERNCONF=ODROIDC2

exit 0

mkdir -p ${DEST}/root
make TARGET=arm64 -s -DNO_ROOT installworld distribution installkernel \
     DESTDIR=${DEST}/root KERNCONF=ODROIDC2

echo "/dev/mmcsd0s3a / ufs rw,noatime 0 0" > ${DEST}/root/etc/fstab
echo "./etc/fstab type=file uname=root gname=wheel mode=0644" >> ${DEST}/root/METALOG

echo "hostname=\"odroidc2\"" > ${DEST}/root/etc/rc.conf
echo "growfs_enable=\"YES\"" >> ${DEST}/root/etc/rc.conf
echo "./etc/rc.conf type=file uname=root gname=wheel mode=0644" >> ${DEST}/root/METALOG

touch ${DEST}/root/firstboot
echo "./firstboot type=file uname=root gname=wheel mode=0644" >> ${DEST}/root/METALOG

makefs -t ffs -B little -F ${DEST}/root/METALOG ${DEST2}/ufs.img ${DEST}/root

mkimg -s bsd -p freebsd-ufs:=${DEST2}/ufs.img -o ${DEST2}/ufs_part.img

newfs_msdos -C 128m -F 16 ${DEST2}/fat.img

rm -f ${DEST2}/odroidc2.dtb
cp ${DEST}/root/boot/dtb/odroidc2.dtb ${DEST2}/odroidc2.dtb
mcopy -i ${DEST2}/fat.img ${DEST2}/odroidc2.dtb  ::
mcopy -i ${DEST2}/fat.img ${FIRMWAREDIR}/uEnv.txt ::
mcopy -i ${DEST2}/fat.img ${DEST}/root/boot/kernel/kernel ::

bl1_position=1  # sector
uboot_position=97  # sector
uboot_env=1440  # sector

mkimg -s mbr -p prepboot:-'dd if=/dev/zero bs=512 count=2047' -p fat16b:=${DEST2}/fat.img -p freebsd:=${DEST2}/ufs_part.img \
mkimg -s mbr -b bootcode.bin -p prepboot:-'dd if=/dev/zero bs=1m count=20' -p fat16b:=${DEST2}/fat.img -p freebsd:=${DEST2}/ufs_part.img \
    -o ${DEST2}/c2.img

# See http://odroid.com/dokuwiki/doku.php?id=en:c2_partition_table
# dd if=ubuntu64-16.04lts-mate-odroid-c2-20160226.img of=bootcode.bin bs=512 count=1
# dd if=ubuntu64-16.04lts-mate-odroid-c2-20160226.img of=bl1.bin bs=512 count=96 skip=1
# dd if=ubuntu64-16.04lts-mate-odroid-c2-20160226.img of=u-boot.bin bs=512 count=1335 skip=97
# dd if=ubuntu64-16.04lts-mate-odroid-c2-20160226.img of=u-boot-env.bin bs=512 count=64 skip=1440

dd if=${FIRMWAREDIR}/bl1.bin conv=notrunc bs=512 seek=$bl1_position of=${DEST2}/c2.img
dd if=${FIRMWAREDIR}/u-boot.bin conv=notrunc bs=512 seek=$uboot_position of=${DEST2}/c2.img
dd if=${FIRMWAREDIR}/u-boot-env.bin conv=notrunc bs=1024 seek=$uboot_env of=${DEST2}/c2.img
