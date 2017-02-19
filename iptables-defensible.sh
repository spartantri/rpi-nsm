#!/bin/bash
sudo apt-get install -y ipset
ipset create blacklist hash:net
iptables -I INPUT -m set --match-set blacklist src -j DROP
iptables -I OUTPUT -m set --match-set blacklist src -j DROP
