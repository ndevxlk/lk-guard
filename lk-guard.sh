#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo -e '\nYou must run this script as the root user!\n'
    exit 1
fi
sudo apt install ipset -y > /dev/null 2>&1
sudo apt install iptables-persistent -y > /dev/null 2>&1
sudo wget -4 -O lk.txt 'https://raw.githubusercontent.com/ndevxlk/lk-guard/main/lk.txt' > /dev/null 2>&1
sudo wget -4 -O cdn.txt 'https://raw.githubusercontent.com/ndevxlk/lk-guard/main/cdn.txt' > /dev/null 2>&1
sudo iptables -F INPUT
sudo ipset destroy lk > /dev/null 2>&1
sudo ipset destroy cdn > /dev/null 2>&1
sudo ipset restore <<EOF
create lk hash:net family inet
$(sed 's/^/add lk /' lk.txt)
EOF
sudo ipset restore <<EOF
create cdn hash:net family inet
$(sed 's/^/add cdn /' cdn.txt)
EOF
sudo rm lk.txt
sudo rm cdn.txt
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -m set --match-set lk src -j ACCEPT
sudo iptables -A INPUT -m set --match-set cdn src -j ACCEPT
sudo iptables -A INPUT -j DROP
sudo iptables-save > /etc/iptables/rules.v4
echo -e '\nFirewall rules have been applied successfully.\n'