```
opkg install openvpn-openssl
Installing openvpn-openssl (2.3.4-2) to root...
Downloading http://upgradeipk.ikcd.net/upgrade_file/ralink-HC5661/1.2.5.15805s/packages/openvpn-openssl_2.3.4-2_ralink.ipk.
Installing liblzo (2.06-20130614.1) to root...
Downloading http://upgradeipk.ikcd.net/upgrade_file/ralink-HC5661/1.2.5.15805s/packages/liblzo_2.06-20130614.1_ralink.ipk.
Configuring liblzo.
Configuring openvpn-openssl.
```

# /etc/rc.local

```
insmod tun
openvpn --cd /etc/openvpn/conf --config config.ovpn&
```

# /etc/openvpn/conf/config.ovpn

```
script-security 2
up up.sh
down down.sh
```
