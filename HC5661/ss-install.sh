###############shadowsocks###############
#安装好shadowsocks的luci，特别记得enable好
#local: 1080
#redir: 1081
#tunnel: 5353 to 8.8.8.8:53
#自动会带上config，但是server/rules是没什么用的

if [ $# -ne 4 ]; then
  echo "Usage: ss-install.sh [server_ip] [server_port] [local_port] [password]"
  exit 1
fi

###############dnsmasq###############
opkg remove dnsmasq
opkg install dnsmasq-full

if [ `grep conf-dir /etc/dnsmasq.conf|wc -l` -eq 0 ]; then
  echo "conf-dir=/etc/dnsmasq.d">>/etc/dnsmasq.conf
fi

mkdir /etc/dnsmasq.d
curl -k https://raw.githubusercontent.com/orzroa/gfwlist2dnsmasq/master/dnsmasq_gfwlist_ipset.conf -o /etc/dnsmasq.d/dnsmasq_gfwlist_ipset.conf

/etc/init.d/dnsmasq restart

###############firewall###############
cat>/usr/bin/ss-iptable<<EOF
iptables -t nat -N shadowsocks
iptables -t nat -A shadowsocks -p tcp -j REDIRECT --to-ports 1081
iptables -t nat -A shadowsocks -p udp -j REDIRECT --to-ports 1081
iptables -t nat -A shadowsocks -p icmp -j REDIRECT --to-ports 1081

ipset create gfwlist hash:ip
iptables -t nat -A PREROUTING -m set --match-set gfwlist dst -j shadowsocks
EOF

chmod a+x /usr/bin/ss-iptable
/usr/bin/ss-iptable

if [ `grep ss-iptable /etc/rc.local|wc -l` -eq 0 ]; then
  sed -i 's/exit/\/usr\/bin\/ss-iptable\nexit/g' /etc/rc.local
fi
