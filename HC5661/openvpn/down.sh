#!/bin/sh

iptables -D FORWARD -o tun0 -j ACCEPT
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.10.0/24 -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.12.0/24 -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.20.0/24 -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.21.0/24 -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.30.0/24 -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.31.0/24 -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.40.0/24 -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.41.0/24 -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.50.0/24 -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.60.0/24 -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 192.168.211.0/24 -d 192.168.255.0/24 -o tun0 -j MASQUERADE

