#!/bin/bash
cd dirname $0
my_path=`pwd`
sudo apt-get install -y apache2 libapache2-mod-security2
sudo mkdir /etc/apache2/ssl
sudo cp /home/pi/PI_ROOT_CA/certs/`hostname`.server.crt /etc/apache2/ssl/
sudo cp /home/pi/PI_ROOT_CA/private/`hostname`.server.key /etc/apache2/ssl/
sudo a2enmod ssl
sudo ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf

sudo sed -ri "s,(^\s+?SSLCertificateFile\s+).*,\1/etc/apache2/ssl/`hostname`.server.crt," /etc/apache2/sites-enabled/000-default-ssl.conf
sudo sed -ri "s,(^\s+?SSLCertificateKeyFile\s+).*,\1/etc/apache2/ssl/`hostname`.server.key," /etc/apache2/sites-enabled/000-default-ssl.conf
sudo sed -ri "s,\b80\b,8080," /etc/apache2/ports.conf
sudo sed -ri "s,\b443\b,8443," /etc/apache2/ports.conf
wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.0.0.tar.gz -O /home/pi/owasp-modsecurity-crs-v3.0.0.tar.gz 
cd /usr/share
sudo tar -zxvf /home/pi/owasp-modsecurity-crs-v3.0.0.tar.gz
sudo ln -s /usr/share/owasp-modsecurity-crs-3.0.0 /etc/apache2/crs
sudo cp $my_path/crs-3.0.0-setup.conf /etc/apache2/crs/crs-setup.conf
sudo sed -ri "s,(^\s+?IncludeOptional\s+).*,\1/etc/apache2/crs/crs-3.0.0-setup.conf," /etc/apache2/mods-enabled/security2.conf 
sudo ln -s /usr/share/GeoIP/GeoIP.dat /etc/apache2/crs/util/geo-location/GeoIP.dat
