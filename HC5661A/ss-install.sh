if [ $# -ne 4 ]; then
  echo "Usage: ss-install.sh [server_ip] [server_port] [local_port] [password]"
  exit 1
fi

###############ipset###############
#if [ `grep gfwlist /etc/rc.local|wc -l` -eq 0 ]; then
#  sed -i 's/exit/ipset create gfwlist hash:ip\nexit/g' /etc/rc.local
#fi
#
#ipset create gfwlist hash:ip
#
###############dnsmasq###############
if [ `grep conf-dir /etc/dnsmasq.conf|wc -l` -eq 0 ]; then
  echo "conf-dir=/etc/dnsmasq.d">>/etc/dnsmasq.conf
fi

mkdir /etc/dnsmasq.d
curl -k https://raw.githubusercontent.com/orzroa/gfwlist2dnsmasq/master/dnsmasq_gfwlist_ipset.conf -o /etc/dnsmasq.d/dnsmasq_gfwlist_ipset.conf

/etc/init.d/dnsmasq restart

###############shadowsocks###############
opkg update
opkg install shadowsocks-libev

cat>/etc/config/shadowsocks.conf<<EOF
{
"server":"$1",
"server_port":$2,
"local_address": "0.0.0.0",
"local_port":$3,
"password":"$4",
"timeout":300,
"method":"aes-256-cfb",
"fast_open": true
}
EOF

cat>/etc/init.d/shadowsocks<<EOF
#!/bin/sh /etc/rc.common

START=95

start() {
	ss-local  -c /etc/config/shadowsocks.conf -u -f '/var/run/ss-local.pid'
	ss-redir  -c /etc/config/shadowsocks.conf -l 1081 -f '/var/run/ss-redir.pid'
	ss-tunnel -c /etc/config/shadowsocks.conf -l 5353 -L 8.8.8.8:53 -u -f '/var/run/ss-tunnel.pid'
	echo 'shadowsocks start success'
}

stop() {
	kill -9 \$(pgrep ss-local)
	rm -f /var/run/ss-local.pid
	
	kill -9 \$(pgrep ss-redir)                                                                                                                                            
	rm -f /var/run/ss-redir.pid
	
	kill -9 \$(pgrep ss-tunnel)                                                                                                                                            
	rm -f /var/run/ss-tunnel.pid
}
EOF

chmod a+x /etc/init.d/shadowsocks
/etc/init.d/shadowsocks enable
/etc/init.d/shadowsocks start

###############firewall###############
cat>/etc/firewall.d/ss-iptable<<EOF
iptables -t nat -N shadowsocks
iptables -t nat -A shadowsocks -p tcp -j REDIRECT --to-ports 1081
iptables -t nat -A shadowsocks -p udp -j REDIRECT --to-ports 1081
iptables -t nat -A shadowsocks -p icmp -j REDIRECT --to-ports 1081

ipset create gfwlist hash:ip
iptables -t nat -A PREROUTING -m set --match-set gfwlist dst -j shadowsocks
EOF

chmod a+x /etc/firewall.d/ss-iptable
/etc/firewall.d/ss-iptable
