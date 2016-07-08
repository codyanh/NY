#!/bin/sh
/usr/bin/smbclient -c "get weiduan\cacti cacti"  //192.168.10.186/mofei/ -U mofei%MAmachaofan31
pwd=`pwd`
echo
echo "pwd=$pwd"
echo
sudo mount -t smbfs //192.168.10.186/mofei/ /mnt/nuoya/weiduan/ -o iocharset=utf8,username=mofei,password=MAmachaofan31
zip -r cacti.zip /mnt/nuoya/weiduan/weiduan/cacti

