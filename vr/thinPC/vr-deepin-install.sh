####################
# redsocks
sudo apt install redsocks net-tools -y
cd /etc/
sudo curl -x 192.168.60.95:8118 -L --remote-name-all https://raw.githubusercontent.com/orzroa/highwifi/master/vr/thinPC/redsocks.conf

sudo systemctl enable redsocks
sudo systemctl restart redsocks
sudo systemctl status redsocks
sudo netstat -anp|grep redsocks

####################
# ipset
sudo apt install ipset -y
sudo ipset create gfwlist hash:ip
sudo ipset list

####################
# dnsmasq
sudo apt install dnsmasq curl -y
cd /etc/dnsmasq.d/
sudo curl -x 192.168.60.95:8118 -L --remote-name-all https://raw.githubusercontent.com/orzroa/gfwlist2dnsmasq/master/{dnsmasq_gfwlist_ipset.conf}

sudo sh -c "cat>>/etc/dnsmasq.conf<<EOF
server=192.168.60.95
listen-address=127.0.0.1
EOF"

# should after dnsmasq is installed
sudo sh -c "echo 'DNSStubListener=no'>>/etc/systemd/resolved.conf"
sudo systemctl restart systemd-resolved

sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq
sudo systemctl status dnsmasq

sudo sed -i 's/\[main\]/\[main\]\ndns=none/g' /etc/NetworkManager/NetworkManager.conf
sudo sed -i 's/nameserver/#nameserver/g' /etc/resolv.conf
sudo sh -c "echo 'nameserver 127.0.0.1'>>/etc/resolv.conf"
sudo systemctl restart NetworkManager.service

####################
# iptables
cd /usr/bin/
sudo curl -x 192.168.60.95:8118 -L --remote-name-all https://raw.githubusercontent.com/orzroa/highwifi/master/vr/thinPC/ss-iptable

sudo chmod a+x /usr/bin/ss-iptable
sudo /usr/bin/ss-iptable

cd /etc/systemd/system/
sudo curl -x 192.168.60.95:8118 -L --remote-name-all https://raw.githubusercontent.com/orzroa/highwifi/master/vr/thinPC/ss-iptable.service

sudo systemctl enable ss-iptable.service
sudo systemctl restart ss-iptable.service
sudo systemctl status ss-iptable.service

curl google.com

