#!/bin/bash
#
# This version uses September 2016 rpi jessie image, please use this image
#

if [ "$EUID" -ne 0 ]
	then echo "Must be root"
	exit
fi

if [[ $# -lt 1 ]]; 
	then echo "Will proceed with default SSID!"
	echo "Usage:"
	echo "sudo $0 [apName]"
	#exit
fi

IFS= read -s  -p Password: APPASS
#APPASS="$1"
APSSID="rPi3"

if [[ $# -eq 1 ]]; then
	APSSID=$1
        echo "Setting SSID to : $APSSID"
fi

apt-get remove --purge hostapd -y
apt-get install hostapd dnsmasq -y

cat > /etc/systemd/system/hostapd.service <<EOF
[Unit]
Description=Hostapd IEEE 802.11 Access Point
After=sys-subsystem-net-devices-wlan1.device
BindsTo=sys-subsystem-net-devices-wlan1.device

[Service]
Type=forking
PIDFile=/var/run/hostapd.pid
ExecStart=/usr/sbin/hostapd -B /etc/hostapd/hostapd.conf -P /var/run/hostapd.pid

[Install]
WantedBy=multi-user.target

EOF

cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
dhcp-range=10.3.2.100,10.3.2.250,255.255.255.0,12h
EOF

cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan1
hw_mode=g
channel=11
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
wpa_passphrase=$APPASS
ssid=$APSSID
EOF

sed -i -- 's/allow-hotplug wlan1//g' /etc/network/interfaces
sed -i -- 's/iface wlan1 inet manual//g' /etc/network/interfaces
sed -i -- 's/    wpa-conf \/etc\/wpa_supplicant\/wpa_supplicant.conf//g' /etc/network/interfaces

cat >> /etc/network/interfaces <<EOF
	wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

# Added by rPi Access Point Setup
allow-hotplug wlan0
iface wlan0 inet static
	address 10.3.2.1
	netmask 255.255.255.0
	network 10.3.2.0
	broadcast 10.0.0.255

EOF

echo "denyinterfaces wlan1" >> /etc/dhcpcd.conf

systemctl enable hostapd

echo "All done! Please reboot"