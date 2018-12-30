###############firewall###############
iptables -t nat -F shadowsocks
iptables -t nat -D PREROUTING -m set --match-set gfwlist dst -j shadowsocks

ipset destroy gfwlist

cat>/usr/bin/ss-iptable<<EOF
EOF

###############dnsmasq###############
if [ `grep conf-dir /etc/dnsmasq.conf|wc -l` -eq 0 ]; then
  echo "conf-dir=/etc/dnsmasq.d">>/etc/dnsmasq.conf
fi

rm /etc/dnsmasq.d/dnsmasq_gfwlist_ipset.conf
rm /etc/dnsmasq.d/speed.conf

/etc/init.d/dnsmasq restart

###############shadowsocks###############
/etc/init.d/shadowsocks-libev stop
/etc/init.d/shadowsocks-libev disable
rm /etc/config/shadowsocks-libev

opkg remove shadowsocks-libev-ss-rules shadowsocks-libev-ss-local shadowsocks-libev-ss-redir shadowsocks-libev-ss-tunnel shadowsocks-libev-config
