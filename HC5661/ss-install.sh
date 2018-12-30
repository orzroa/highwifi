if [ $# -ne 4 ]; then
  echo "Usage: ss-install.sh [server_ip] [server_port] [password]"
  exit 1
fi

###############dnsmasq###############
opkg remove dnsmasq
opkg install dnsmasq-full

if [ `grep conf-dir /etc/dnsmasq.conf|wc -l` -eq 0 ]; then
  echo "conf-dir=/etc/dnsmasq.d">>/etc/dnsmasq.conf
  echo "conf-dir added into dnsmasq.conf"
fi

mkdir /etc/dnsmasq.d
curl -k https://raw.githubusercontent.com/orzroa/gfwlist2dnsmasq/master/dnsmasq_gfwlist_ipset.conf -o /etc/dnsmasq.d/dnsmasq_gfwlist_ipset.conf
curl -k https://raw.githubusercontent.com/orzroa/highwifi/master/HC5661/speed.conf -o /etc/dnsmasq.d/speed.conf

/etc/init.d/dnsmasq restart

###############shadowsocks###############
#安装好shadowsocks的luci，特别记得enable好
#local: 1080
#redir: 1081
#tunnel: 5353 to 8.8.8.8:53
#自动会带上config，但是server/rules是没什么用的

opkg update
opkg install shadowsocks-libev-config
opkg install shadowsocks-libev-ss-local
opkg install shadowsocks-libev-ss-redir
opkg install shadowsocks-libev-ss-rules
opkg install shadowsocks-libev-ss-tunnel

cat>/etc/config/shadowsocks-libev<<EOF
config ss_local
	option server 'sss0'
	option local_address '0.0.0.0'
	option local_port '1080'
	option timeout '30'
	option mode 'tcp_and_udp'
	option fast_open '1'

config ss_tunnel
	option server 'sss0'
	option local_address '0.0.0.0'
	option mode 'tcp_and_udp'
	option timeout '60'
	option local_port '5353'
	option tunnel_address '8.8.8.8:53'

config ss_redir 'hi'
	option server 'sss0'
	option local_address '0.0.0.0'
	option mode 'tcp_and_udp'
	option timeout '60'
	option fast_open '1'
	option verbose '1'
	option reuse_port '1'
	option local_port '1081'

config ss_rules 'ss_rules'
	option disabled '1'
	option redir_tcp 'hi'
	option redir_udp 'hi'
	option src_default 'checkdst'
	option dst_default 'bypass'
	option local_default 'checkdst'
	list src_ips_forward '192.168.1.4'
	option dst_forward_recentrst '0'
	list dst_ips_forward '8.8.8.8'

config server 'sss0'
	option method 'aes-256-cfb'
	option server "$1"
	option server_port "$2"
	option password "$3"
EOF

chmod a+x /etc/init.d/shadowsocks-libev
/etc/init.d/shadowsocks-libev enable
/etc/init.d/shadowsocks-libev start

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
  echo "ss-iptables added into rc.local"
fi
