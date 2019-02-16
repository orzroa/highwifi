#!/bin/sh

self=`uci get system.@system[0].hostname`'v'

ip=`ifconfig|egrep 10.8.7.[0-9]{1,3} -o|head -1`
if [ -z $ip ]; then
  echo "empty ip"
  exit 0
else
  echo "ip=$ip"
fi

ip_on_dns=`nslookup $self.scieny.win|egrep 10.8.7.[0-9]{1,3} -o|head -1`
if [ -z $ip_on_dns ]; then
  echo "empty ip_on_dns"
  exit 0
else
  echo "ip_on_dns=$ip_on_dns"
fi

if [ "$ip" != "$ip_on_dns" ]; then
  echo "dns updated"
else
  echo "dns up-to-date"
fi
