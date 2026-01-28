#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo -e '\nYou must run this script as the root user!\n'
    exit 1
fi
sudo apt install ipset -y > /dev/null 2>&1
sudo apt install iptables-persistent -y > /dev/null 2>&1
sudo wget -4 -O lk_ipv4.txt 'https://raw.githubusercontent.com/ndevxlk/lk-guard/main/lk_ipv4.txt' > /dev/null 2>&1
sudo wget -4 -O lk_ipv6.txt 'https://raw.githubusercontent.com/ndevxlk/lk-guard/main/lk_ipv6.txt' > /dev/null 2>&1
sudo wget -4 -O cdn_ipv4.txt 'https://raw.githubusercontent.com/ndevxlk/lk-guard/main/cdn_ipv4.txt' > /dev/null 2>&1
sudo wget -4 -O cdn_ipv6.txt 'https://raw.githubusercontent.com/ndevxlk/lk-guard/main/cdn_ipv6.txt' > /dev/null 2>&1
sudo iptables -F INPUT
sudo ip6tables -F INPUT
sudo ipset destroy lk_ipv4 > /dev/null 2>&1
sudo ipset destroy lk_ipv6 > /dev/null 2>&1
sudo ipset destroy cdn_ipv4 > /dev/null 2>&1
sudo ipset destroy cdn_ipv6 > /dev/null 2>&1
sudo ipset restore <<EOF
create lk_ipv4 hash:net family inet
$(sed 's/^/add lk_ipv4 /' lk_ipv4.txt)
EOF
sudo ipset restore <<EOF
create lk_ipv6 hash:net family inet6
$(sed 's/^/add lk_ipv6 /' lk_ipv6.txt)
EOF
sudo ipset restore <<EOF
create cdn_ipv4 hash:net family inet
$(sed 's/^/add cdn_ipv4 /' cdn_ipv4.txt)
EOF
sudo ipset restore <<EOF
create cdn_ipv6 hash:net family inet6
$(sed 's/^/add cdn_ipv6 /' cdn_ipv6.txt)
EOF
sudo rm lk_ipv4.txt
sudo rm lk_ipv6.txt
sudo rm cdn_ipv4.txt
sudo rm cdn_ipv6.txt
sudo iptables -A INPUT -i lo -j ACCEPT
sudo ip6tables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -m set --match-set lk_ipv4 src -j ACCEPT
sudo ip6tables -A INPUT -m set --match-set lk_ipv6 src -j ACCEPT
sudo iptables -A INPUT -m set --match-set cdn_ipv4 src -j ACCEPT
sudo ip6tables -A INPUT -m set --match-set cdn_ipv6 src -j ACCEPT
sudo iptables -A INPUT -j DROP
sudo ip6tables -A INPUT -j DROP
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6
echo -e '\nFirewall rules have been applied successfully.\n'