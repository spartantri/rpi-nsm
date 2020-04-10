#!/bin/bash
TEMP=$(mktemp -d /tmp/temp-zeek.XXXXXX)
cd ${TEMP}

#Install pre-requisites
sudo apt-get install -y cmake make gcc g++ flex bison libpcap-dev python-dev swig zlib1g-dev libssl1.0-dev
git clone --recursive https://github.com/zeek/zeek
cd zeek/
./configure --with-pcap=/usr/local/lib
make && sudo make install

echo 'PATH=/usr/local/zeek/bin:$PATH' >> ~/.profile

sudo chown pi -R /usr/local/zeek
sudo chgrp pi -R /usr/local/zeek
