#!/bin/bash

####################
# v2ray
wget https://github.com/v2ray/v2ray-core/releases/download/v4.18.0/v2ray-linux-64.zip
sudo unzip v2ray-linux-64.zip -d /opt/
cd /opt/v2ray
sudo wget https://raw.githubusercontent.com/orzroa/highwifi/master/vr/HC5661/config.json -O /opt/v2ray/config.json

sudo ln -s /opt/v2ray/systemd/v2ray.service /etc/systemd/system/
sudo sed -i 's/usr\/bin/opt/g' systemd/v2ray.service
sudo sed -i 's/etc/opt/g' systemd/v2ray.service

sudo chmod a+x v2ray v2ctl
sudo systemctl enable v2ray
sudo systemctl start v2ray
sudo systemctl status v2ray

####################
# ipset
sudo apt install ipset -y
sudo ipset create gfwlist hash:ip
sudo ipset list

####################
# dnsmasq
sudo apt purge avahi-daemon

sudo systemctl disable systemd-resolved.service
sudo systemctl stop systemd-resolved
sudo sed -i 's/\[main\]/\[main\]\ndns=none/g' /etc/NetworkManager/NetworkManager.conf
sudo systemctl restart NetworkManager.service

sudo apt install dnsmasq curl -y
cd /etc/dnsmasq.d/
sudo curl -L --remote-name-all https://raw.githubusercontent.com/orzroa/gfwlist2dnsmasq/master/{dnsmasq_gfwlist_ipset.conf,dnsmasq_gfwlist_server.conf}

sudo sh -c "cat>>/etc/dnsmasq.conf<<EOF
server=114.114.114.114
server=/mogo.com/192.168.60.95
listen-address=127.0.0.1
EOF"

sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq
sudo systemctl status dnsmasq

sudo rm /etc/resolv.conf
sudo touch /etc/resolv.conf
sudo echo 'nameserver 127.0.0.1'>>/etc/resolv.conf

####################
# iptables
cd /usr/bin/
sudo curl -L --remote-name-all https://raw.githubusercontent.com/orzroa/highwifi/master/vr/thinPC/ss-iptable

sudo chmod a+x /usr/bin/ss-iptable
sudo /usr/bin/ss-iptable

if [ ! -f /etc/rc.local ]; then
  sudo touch /etc/rc.local
  sudo chmod a+x /etc/rc.local
fi

if [ `grep ss-iptable /etc/rc.local|wc -l` -eq 0 ]; then
  if [ `grep exit /etc/rc.local|wc -l` -eq 0 ]; then
    sudo sh -c "echo ''>>/etc/rc.local"
    sudo sh -c "echo '#!/bin/bash\n/usr/bin/ss-iptable\nexit 0'>>/etc/rc.local"
  else
    sudo sh -c "sed -i 's/exit/\/usr\/bin\/ss-iptable\nexit/g' /etc/rc.local"
  fi
  echo "ss-iptables added into rc.local"
fi
cat /etc/rc.local

sudo ln -fs /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service
sudo echo "
[Install]
WantedBy=multi-user.target
Alias=rc-local.service
" >> etc/systemd/system/rc-local.service

curl google.com
