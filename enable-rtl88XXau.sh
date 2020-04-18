#!/bin/bash
sudo apt-get install git bc bison flex libssl-dev libncurses5-dev
cd ..
sudo wget "https://raw.githubusercontent.com/notro/rpi-source/master/rpi-source" -O /usr/bin/rpi-source
sudo chmod 755 /usr/bin/rpi-source
rpi-source
TEMP=$(mktemp -d /tmp/rtl8812u.XXXX)
cd $TEMP
sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/g' Makefile
make
sudo cp 88XXau.ko /lib/modules/`uname -r`/kernel/drivers/net/wireless
sudo depmod -a
sudo modprobe 88XXau
ip a s
iwconfig
