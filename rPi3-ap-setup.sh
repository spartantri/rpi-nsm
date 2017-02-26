#!/bin/bash
#
# This version uses September 2016 rpi jessie image, please use this image
# based on https://gist.github.com/Lewiscowles1986/fecd4de0b45b2029c390 and http://elinux.org/RPI-Wireless-Hotspot

if [ "$EUID" -ne 0 ]
	then echo "Must be root"
	exit
fi

if [[ $# -lt 1 ]]; 
	then echo "Will proceed with default rPi3 SSID!"
	echo "Usage:"
	echo "sudo $0 [apName]"
        echo "Installation will start in 30 seconds, press <CTRL+C> to cancel..."
	sleep 30
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
apt-get install -y hostapd dnsmasq 

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
interface=wlan1
log-facility=/var/log/dnsmasq.log
log-queries
dhcp-range=10.3.2.100,10.3.2.250,255.255.255.0,12h
dhcp-option=3,10.3.2.1
dhcp-option=6,10.3.2.1
server=216.146.35.35
server=8.26.56.26
server=8.20.247.20

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
allow-hotplug wlan1
iface wlan1 inet static
	address 10.3.2.1
	netmask 255.255.255.0
	network 10.3.2.0
	broadcast 10.0.0.255

EOF

echo "denyinterfaces wlan1" >> /etc/dhcpcd.conf

systemctl enable hostapd

##mv /etc/udhcpd.conf /etc/udhcpd.conf.orig
##cat > /etc/udhcpd.conf <<EOF

##start 10.3.2.100 # This is the range of IPs that the hostspot will give to client devices.
##end 10.3.2.250
##interface wlan1 # The device uDHCP listens on.
##remaining yes
##lease_file     /var/lib/misc/udhcpd.leases
##pidfile        /var/run/udhcpd.pid 
##opt dns 216.146.35.35 8.26.56.26 # The DNS servers client devices will use.
##opt subnet 255.255.255.0
##opt router 10.3.2.1 # The Pi's IP address on wlan0 which we will set up shortly.
##opt lease 864000 # 10 day DHCP lease time in seconds

##EOF

sed -i -- 's,#DAEMON_CONF.*,DAEMON_CONF="/etc/hostapd/hostapd.conf",g' /etc/default/hostapd

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sed -i -- 's,#net.ipv4.ip_forward=.*,net.ipv4.ip_forward=1,g' /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan1 -o eth0 -j ACCEPT
iptables -A INPUT ! -s 10.3.2.1/24 -p tcp -m multiport --dports 53,514 -m state --state NEW,ESTABLISHED -j REJECT
iptables -A INPUT ! -s 127.0.0.1/8 -p tcp -m multiport --dports 9200,9300 -m state --state NEW,ESTABLISHED -j REJECT
iptables -t nat -A PREROUTING -p tcp --dport 80 -i eth0 -j DNAT --to 127.0.0.1:8080
iptables -t nat -A PREROUTING -p tcp --dport 443 -i eth0 -j DNAT --to 127.0.0.1:8443
iptables -t nat -A POSTROUTING -s 10.3.2.1/24 -o eth0 -j MASQUERADE
sh -c "iptables-save > /etc/iptables.ipv4.nat"
echo "up iptables-restore < /etc/iptables.ipv4.nat" >> /etc/network/interfaces

##service udhcpd start
##update-rc.d hostapd enable
##update-rc.d udhcpd enable

echo "All done! Please reboot"
