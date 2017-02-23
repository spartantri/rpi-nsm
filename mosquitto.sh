#!/bin/bash

if [ "$EUID" -ne 0 ]
        then echo -e "Must be root\n usage: sudo $0"
        exit
fi

read -p "Enter username to use for IOT MQTT (user1): " mqttUser
mqttUser=${mqttUser:-user1}


apt-get install -y mosquitto mosquitto-clients python-mosquitto

#Install and generate certificates
cd /home/pi
git clone https://github.com/spartantri/easy-ca.git
cd easy-ca
./create-root-ca -d /home/pi/PI_ROOT_CA
cd /home/pi/PI_ROOT_CA
bin/create-server -s `hostname`
cp ca/ca.crt /etc/mosquitto/ca_certificates/
cp crl/ca.crl /etc/mosquitto/ca_certificates/
cp certs/`hostname`.server.crt /etc/mosquitto/certs/
cp private/`hostname`.server.key /etc/mosquitto/certs/

mosquitto_passwd -c /etc/mosquitto/passwd_mqtt $mqttUser

#Generate mosquitto configuration

cat > /etc/mosquitto/mosquitto.conf << EOF

# Place your local configuration in /etc/mosquitto/conf.d/
#
# A full description of the configuration file is at
# /usr/share/doc/mosquitto/examples/mosquitto.conf.example

allow_anonymous false
password_file /etc/mosquitto/passwd_mqtt

pid_file /var/run/mosquitto.pid

persistence true
persistence_location /var/lib/mosquitto/

log_dest file /var/log/mosquitto/mosquitto.log

include_dir /etc/mosquitto/conf.d

log_type error
log_type warning
log_type notice
log_type information

connection_messages true
log_timestamp true

# MQTT over TLS/SSL
listener 8883
cafile /etc/mosquitto/ca_certificates/ca.crt
certfile /etc/mosquitto/certs/`hostname`.crt
keyfile /etc/mosquitto/certs/`hostname`.key
#require_certificate true
#use_identity_as_username true
crlfile /etc/mosquitto/ca_certificates/ca.crl

#Testing service
read -p "Enter password for ${mqttUser} : " mqttPass

sleep 2 && mosquitto_pub --cafile /etc/mosquitto/ca_certificates/ca.crt -d -t test_mqtt -m "MQTT mosquitto test successful! PRESS <CTRL+C>" -u $mqttUser -P $mqttPass -h `hostname` -p 8883 &
mosquitto_sub --cafile /etc/mosquitto/ca_certificates/ca.crt -d -t test_mqtt -u $mqttUser -P $mqttPass -h `hostname` -p 8883

EOF
