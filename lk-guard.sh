#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo -e '\nYou must run this script as the root user!\n'
    exit 1
fi
sudo wget -4 -q -O lk.txt 'https://raw.githubusercontent.com/ndevxlk/lk-guard/main/lk.txt'
sudo wget -4 -q -O cdn.txt 'https://raw.githubusercontent.com/ndevxlk/lk-guard/main/cdn.txt'
sudo iptables -F INPUT
sudo ipset destroy allowlist 2>/dev/null
sudo ipset restore <<EOF
create allowlist hash:net family inet
$(sed 's/^/add allowlist /' lk.txt)
$(sed 's/^/add allowlist /' cdn.txt)
EOF
sudo rm lk.txt cdn.txt
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -m set --match-set allowlist src -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -j DROP
sudo iptables -A INPUT -p udp -m multiport --dports 53,443 -m set --match-set allowlist src -j ACCEPT
sudo iptables -A INPUT -p udp -m multiport --dports 53,443 -j DROP
sudo iptables -A INPUT -p icmp -j DROP
echo -e '\nFirewall rules have been applied successfully.\n'