#!/bin/sh

mkdir /var/dnsmasq.d
cd /var/dnsmasq.d

oldMD5=`cat /var/dnsmasq.d/conf.md5`
echo "oldMD5=$oldMD5"
newMD5=`curl -s https://raw.githubusercontent.com/orzroa/gfwlist2dnsmasq/master/conf.md5`
echo "newMD5=$newMD5"

if [ -z "$newMD5" ]; then
  echo "newMD5 is empty"
  exit
fi

if [ "$oldMD5" != "$newMD5" ]; then
  curl -s -O https://raw.githubusercontent.com/orzroa/gfwlist2dnsmasq/master/dnsmasq_gfwlist_ipset.conf
  curl -s -O https://raw.githubusercontent.com/orzroa/gfwlist2dnsmasq/master/speed.conf
  dldMD5=`cat *.conf|md5sum|cut -d' ' -f1`
  echo "dldMD5=$dldMD5"
  if [ "$dldMD5" != "$newMD5" ]; then
    echo 'Downloaded file md5 check error!'
  else
    mv -f *.conf /etc/dnsmasq.d/
    echo "$dldMD5" >/var/dnsmasq.d/conf.md5
    /etc/init.d/dnsmasq restart
    echo 'File updated!'
  fi
fi

