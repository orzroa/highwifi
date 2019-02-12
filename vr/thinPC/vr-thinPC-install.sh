
# v2ray
mkdir -p /opt/v2ray
cd /opt/v2ray
wget -e "https_proxy=192.168.60.95:8118" https://github.com/v2ray/v2ray-core/releases/download/v4.15.0/v2ray-linux-64.zip
unzip v2ray-linux-64.zip
mv config.json config.json.sample
wget -e "https_proxy=192.168.60.95:8118" https://raw.githubusercontent.com/orzroa/highwifi/master/vr/thinPC/config.json



# dnsmasq

# ipset
cat>/usr/bin/ss-iptable<<EOF
iptables -t nat -N shadowsocks
iptables -t nat -A shadowsocks -p tcp -j REDIRECT --to-ports 1081
iptables -t nat -A shadowsocks -p udp -j REDIRECT --to-ports 1081
iptables -t nat -A shadowsocks -p icmp -j REDIRECT --to-ports 1081
ipset create gfwlist hash:ip
iptables -t nat -A PREROUTING -m set --match-set gfwlist dst -j shadowsocks
iptables -t nat -A OUTPUT -m set --match-set gfwlist dst -j shadowsocks
EOF

chmod a+x /usr/bin/ss-iptable
/usr/bin/ss-iptable

if [ `grep ss-iptable /etc/rc.local|wc -l` -eq 0 ]; then
  sed -i 's/exit/\/usr\/bin\/ss-iptable\nexit/g' /etc/rc.local
  echo "ss-iptables added into rc.local"
fi

# iptables


# persistent
