#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo -e '\nYou must run this script as the root user!\n'
    exit 1
fi
sudo wget -4 -q -O lk.txt 'https://raw.githubusercontent.com/ndevxlk/lk-guard/main/lk.txt'
sudo wget -4 -q -O cdn.txt 'https://raw.githubusercontent.com/ndevxlk/lk-guard/main/cdn.txt'
sudo iptables -F INPUT
sudo iptables -F OUTPUT
sudo ipset restore <<EOF
create allowlist hash:net family inet -exist
flush allowlist
$(sed 's/^/add allowlist /' lk.txt)
$(sed 's/^/add allowlist /' cdn.txt)
EOF
sudo rm lk.txt cdn.txt
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -m set --match-set allowlist src -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -j DROP
sudo iptables -A INPUT -p udp -m set --match-set allowlist src -j ACCEPT
sudo iptables -A INPUT -p udp -j DROP
sudo iptables -A INPUT -p icmp -j DROP
sudo iptables -A OUTPUT -p tcp --dport 1024:65535 -m string --algo bm --string "BitTorrent protocol" -j DROP
sudo iptables -A OUTPUT -p udp --dport 1024:65535 -m string --algo bm --hex-string "|000004172710198000000000|" -j DROP
echo -e '\nFirewall rules have been applied successfully.\n'