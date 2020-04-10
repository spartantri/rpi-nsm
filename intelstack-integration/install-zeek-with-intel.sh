#!/bin/bash

#Install IntelStack repositories
sudo bash script.deb.sh

#Install pre-requisites
bash install-libpcap.sh

#Install zeek
bash install-zeek.sh

#Install IntelStack client
sudo apt-get install intel-stack-client 
#sudo chown intel-stack-client -R /opt/intel-stack-client
sudo intel-stack-client nsm zeek
#sudo -u intel-stack-client -g intel-stack-client intel-stack-client nsm zeek

IFS= read -s  -p IntelStack-API-key: APIKEY
sudo intel-stack-client api $APIKEY
sudo intel-stack-client config --set zeek.restart=true
intel-stack-client list
intel-stack-client pull
