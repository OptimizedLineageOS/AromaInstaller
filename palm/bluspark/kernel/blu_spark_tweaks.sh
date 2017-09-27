#!/sbin/sh

fstrim -v /cache
fstrim -v /data

dd if=/dev/block/bootdevice/by-name/boot of=/tmp1/boot.img
/tmp1/unpackbootimg -i /tmp1/boot.img -o /tmp1/

mkdir /tmp1/ramdisk
cp /tmp1/boot.img-ramdisk.gz /tmp1/ramdisk/
cd /tmp1/ramdisk/
gunzip -c /tmp1/ramdisk/boot.img-ramdisk.gz | cpio -i
rm /tmp1/boot.img-ramdisk.gz
rm /tmp1/ramdisk/boot.img-ramdisk.gz
rm /tmp1/ramdisk/init.blu_spark.rc
rm /tmp1/ramdisk/fstab.qcom
cp /tmp1/init.blu_spark.rc /tmp1/ramdisk/
cp /tmp1/fstab.qcom /tmp1/ramdisk/

if ! grep -q 'blu_spark' /tmp1/ramdisk/init.rc; then
   sed -i '1i import /init.blu_spark.rc' /tmp1/ramdisk/init.rc
   sed -i "s/swapon_all fstab.qcom//" /tmp1/ramdisk/init.target.rc
fi;

if ! grep -q 'bg_apps' /tmp1/ramdisk/default.prop; then
   echo "ro.sys.fw.bg_apps_limit=60" >> /tmp1/ramdisk/default.prop
fi;

if getprop ro.crypto.type | grep -q 'file'; then
   sed -i "s/encryptable=footer/fileencryption=ice/" /tmp1/ramdisk/fstab.qcom
fi;

chmod 750 /tmp1/ramdisk/init.blu_spark.rc
chmod 640 /tmp1/ramdisk/fstab.qcom

find . | cpio -o -H newc | gzip > /tmp1/boot.img-ramdisk.gz
rm -r /tmp1/ramdisk

/tmp1/mkbootimg --kernel /tmp1/Image.gz-dtb --ramdisk /tmp1/boot.img-ramdisk.gz --cmdline "$(cat /tmp1/boot.img-cmdline)" --base 0x80000000 --pagesize 4096 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 -o /tmp1/newboot.img
dd if=/tmp1/newboot.img of=/dev/block/bootdevice/by-name/boot
