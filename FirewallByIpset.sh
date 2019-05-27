#!/bin/bash

########## whois3 ##########
wget http://ftp.apnic.net/apnic/dbase/tools/ripe-dbase-client-v3.tar.gz 
tar xzvf ripe-dbase-client-v3.tar.gz 
cd whois-3.1 
./configure 
make 
mv whois3 /usr/bin

########## ipset ##########
ipset create sc hash:ip
ipset add sc 127.0.0.1

ipset create cmcc hash:net
for emm in `curl -s https://ispip.clang.cn/cmcc_cidr.txt`; do /sbin/ipset add -exist cmcc $emm; done; 

ipset create ctcc-sh hash:net
for emm in `whois3 -h whois.apnic.net -l -i ml MAINT-CHINANET-SH|grep inetnum:|awk '{print $2"-"$4}'`;do /sbin/ipset add -exist ctcc-sh $emm; done;

cat>/etc/systemd/system/ipset-persistent.service<<EOF
[Unit]
Description=ipset persistent configuration
#
DefaultDependencies=no
Before=network.target

# ipset sets should be loaded before iptables
# Because creating iptables rules with names of non-existent sets is not possible
Before=netfilter-persistent.service
Before=ufw.service

ConditionFileNotEmpty=/etc/iptables/ipset

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/sbin/ipset restore -file /etc/iptables/ipset
# Uncomment to save changed sets on reboot
# ExecStop=/sbin/ipset save -file /etc/iptables/ipset
ExecStop=/sbin/ipset flush
ExecStopPost=/sbin/ipset destroy

[Install]
WantedBy=multi-user.target

RequiredBy=netfilter-persistent.service
RequiredBy=ufw.service
EOF

systemctl daemon-reload
systemctl enable ipset-persistent.service

########## 手工添加定时器 ##########
# persistent by /etc/systemd/system/ipset-persistent.service
48   1  *  * * for emm in `whois3 -h whois.apnic.net -l -i ml MAINT-CHINANET-SH|grep inetnum:|awk '{print $2"-"$4}'`;do /sbin/ipset add -exist ctcc-sh $emm; done;
48   1  *  * * for emm in `curl -s https://ispip.clang.cn/cmcc_cidr.txt`; do /sbin/ipset add -exist cmcc $emm; done; 
# iptables

########## iptables ##########
iptables -N IPSET
iptables -A IPSET -p tcp -m set --match-set sc src -j ACCEPT
iptables -A IPSET -p tcp -m set --match-set ctcc-sh src -j ACCEPT
iptables -A IPSET -p tcp -m set --match-set cmcc src -j ACCEPT
iptables -A IPSET -p udp -m set --match-set sc src -j ACCEPT
iptables -A IPSET -p udp -m set --match-set cmcc src -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 911,933,1443 -j IPSET
