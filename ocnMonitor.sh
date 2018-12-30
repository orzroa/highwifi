#!/bin/sh

. /root/env

function echo_eval(){
  echo $1
  echo_eval_result=`eval $1`
  echo $echo_eval_result
}

echo "==========================="
date

echo_eval "curl -s --connect-timeout 3 --retry 3 $grain_url --data \"domain=0&channel=0&token=$grain_token\" | wc -l"

echo_eval "curl -s --connect-timeout 3 --retry 3 'http://www.sohu.com' | wc -l"

if [ $echo_eval_result -eq 0 ]; then
  echo_eval "curl $ocn_router_url --user admin:$ocn_router_pass --data 'test=1'"
  echo_eval "curl $ocn_router_url --user admin:$ocn_router_pass --data \"!!InternetGatewayDevice.WANDevice.1.WANConnectionDevice.3.WANIPConnection.1.Enable!=false&!!InternetGatewayDevice.WANDevice.1.WANConnectionDevice.3.WANIPConnection.2.Enable!=false&!!InternetGatewayDevice.WANDevice.1.WANConnectionDevice.3.WANPPPConnection.1.Enable!=false&!!InternetGatewayDevice.WANDevice.1.WANConnectionDevice.3.WANPPPConnection.1.Username!=$ocn_wan_user&!!InternetGatewayDevice.WANDevice.1.WANConnectionDevice.3.WANPPPConnection.1.Password!=$ocn_wan_pass&!!InternetGatewayDevice.WANDevice.1.WANConnectionDevice.3.WANPPPConnection.1.Enable!=true&SUBMIT=END\""
  echo_eval "curl $ocn_router_url --user admin:$ocn_router_pass --data \"!!InternetGatewayDevice.LANDevice.3.WLANConfiguration.1.SSID!=$ocn_wifi_ssid&!!InternetGatewayDevice.LANDevice.3.WLANConfiguration.1.PreSharedKey.1.PreSharedKey!=$ocn_wifi_pass&SUBMIT=END\""
fi

