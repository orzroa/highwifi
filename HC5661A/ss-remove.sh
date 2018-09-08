###############ipset###############
#if [ `grep gfwlist /etc/rc.local|wc -l` -gt 0 ]; then
#  sed -i 's/ipset create gfwlist hash:ip//g' /etc/rc.local
#fi
#
###############dnsmasq###############
if [ `grep conf-dir /etc/dnsmasq.conf|wc -l` -eq 0 ]; then
  echo "conf-dir=/etc/dnsmasq.d">>/etc/dnsmasq.conf
fi

rm /etc/dnsmasq.d/dnsmasq_gfwlist_ipset.conf

###############shadowsocks###############
/etc/init.d/shadowsocks stop
/etc/init.d/shadowsocks disable
rm /etc/config/shadowsocks.conf /etc/init.d/shadowsocks

opkg remove shadowsocks-libev

###############firewall###############
iptables -t nat -F shadowsocks
#iptables -t nat -D PREROUTING -s 192.168.12.0/24 -j shadowsocks
#iptables -t nat -D PREROUTING -s 192.168.0.0/16 -j shadowsocks
iptables -t nat -D PREROUTING -m set --match-set gfwlist dst -j shadowsocks

rm /etc/firewall.d/ss-iptable
