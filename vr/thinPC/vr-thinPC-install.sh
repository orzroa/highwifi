####################
# v2ray
mkdir -p /opt/v2ray
cd /opt/v2ray

curl -x 192.168.60.95:8118 -L --remote-name-all https://github.com/v2ray/v2ray-core/releases/download/v4.15.0/v2ray-linux-64.zip
unzip v2ray-linux-64.zip

mv config.json config.json.sample
curl -x 192.168.60.95:8118 -L --remote-name-all https://raw.githubusercontent.com/orzroa/highwifi/master/vr/thinPC/{config.json,v2ray.service}

chmod +x v2ray v2ctl v2ray.service
cp v2ray.service /etc/systemd/system/v2ray.service
systemctl enable v2ray
systemctl start v2ray
systemctl status v2ray
netstat -anp|grep v2ray

####################
# ipset
yum install ipset -y
ipset create gfwlist hash:ip
ipset list

####################
# dnsmasq
yum install dnsmasq bind-utils -y
cd /etc/dnsmasq.d/
curl -x 192.168.60.95:8118 -L --remote-name-all https://raw.githubusercontent.com/orzroa/gfwlist2dnsmasq/master/{dnsmasq_gfwlist_ipset.conf}

cat>>/etc/dnsmasq.conf<<EOF

server=192.168.60.95
listen-address=127.0.0.1
EOF

## in case of SELinux
semanage permissive -a dnsmasq_t

systemctl enable dnsmasq
systemctl start dnsmasq
systemctl status dnsmasq

sed -i 's/\[main\]/\[main\]\ndns=none/g' /etc/NetworkManager/NetworkManager.conf
sed -i 's/nameserver/#nameserver/g' /etc/resolv.conf
echo 'nameserver 127.0.0.1'>>/etc/resolv.conf
systemctl restart NetworkManager.service

####################
# iptables
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
  if [ `grep exit /etc/rc.local|wc -l` -eq 0 ]; then
    echo ''>>/etc/rc.local
    echo '/usr/bin/ss-iptable'>>/etc/rc.local
  else
    sed -i 's/exit/\/usr\/bin\/ss-iptable\nexit/g' /etc/rc.local
  fi
  echo "ss-iptables added into rc.local"
fi
cat /etc/rc.local

curl google.com

# if jenkins uses 5353
# vim /etc/sysconfig/jenkins
# find JENKINS_JAVA_OPTIONS
# add "-Dhudson.udp=-1 -Dhudson.DNSMultiCast.disabled=true"
# service jenkins restart

