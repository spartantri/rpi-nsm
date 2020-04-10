#!/bin/bash
TEMP=$(mktemp -d /tmp/temp-libpcap.XXXXXX)

#Install pre-requisites
sudo apt-get install build-essential flex bison

cd ${TEMP}
wget https://www.tcpdump.org/release/libpcap-1.9.1.tar.gz
tar xzvf libpcap-1.9.1.tar.gz
cd libpcap-1.9.1/
./configure
make
sudo make install
