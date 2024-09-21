#!/bin/bash
###
 # @Author: 喵二
 # @Date: 2023-09-22 09:19:42
 # @LastEditors: 喵二
 # @LastEditTime: 2023-09-22 22:28:57
 # @FilePath: \undefinedd:\Git\catnd\catnd.sh
### 

echo " "
echo " "
echo " "

# Check OpenWrt

if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root user"
    exit 1
fi

release=$(cat /etc/openwrt_release)

if [[ $release =~ "OpenWrt" ]]; then
  echo "$(date) - Starting CatWrt Network Diagnostics"  
else
  echo "Abnormal system environment..."
  echo " "
  exit 1
fi

# Start

clear

# Banner

cat /etc/banner
echo " "
echo " "
echo " "
echo "$(date) - Starting CatWrt Network Diagnostics" 
echo " "

# Ping & PPPoE

ping -c 3 223.5.5.5 > /dev/null
if [ $? -eq 0 ]; then
    echo "[Ping] Network connection succeeded!"
    echo " "
else
    ping -c 3 119.29.29.99 > /dev/null
    if [ $? -eq 0 ]; then
        echo "[Ping] Network connection succeeded,But there may be problems!"
        echo " "
    else
        pppoe_config=$(grep 'pppoe' /etc/config/network)
        if [ ! -z "$pppoe_config" ]; then
            echo "[PPPoE] Please check if your PPPoE account and password are correct."
            echo " "
        fi
        exit 1
    fi
fi

# DNS

valid_dns="1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 223.6.6.6 223.5.5.5 180.76.76.76 208.67.222.222 208.67.220.220 119.29.29.99"

dns_config=$(grep 'option dns' /etc/config/network)
dns_servers=$(echo $dns_config | awk -F "'" '{print $2}')

for ip in $dns_servers; do
  if ! [[ $valid_dns =~ (^|[ ])$ip($|[ ]) ]]; then
    echo "[DNS] Recommended to delete DNS $ip"
    echo " "
    exit 1
  fi
done

# Bad DNS

echo "[DNS] DNS configuration looks good!"
echo " "

bad_dns="114.114.114.114 114.114.115.115 119.29.29.29"
if [[ $dns_config =~ $bad_dns ]]; then
  echo "[DNS] DNS may be polluted or unreliable"
  echo " "
fi

# nslookup

nslookup bilibili.com > /dev/null
if [ $? -ne 0 ]; then
  nslookup www.miaoer.xyz > /dev/null
  if [ $? -eq 0 ]; then  
    echo "[DNS] DNS resolution succeeded"
    echo " "
  else
    echo "[DNS] NS resolution failed for 'www.miaoer.xyz'"
    echo "[DNS] Your DNS server may have issues"
    echo " "
  fi
fi

# Public IP

echo CatWrt IPv4 Addr: $(curl --silent --connect-timeout 5 4.ipw.cn )
echo " "

curl 6.ipw.cn --connect-timeout 5 > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "[IPv6] IPv6 network connection timed out"
  echo " "
else
  echo CatWrt IPv6 Addr: $(curl --silent 6.ipw.cn) 
  echo " "
fi

# IPv6

resp=$(curl --silent test.ipw.cn)

if echo "$resp" | grep -q -E '240e|2408|2409|2401'; then
  echo "[IPv6] IPv6 access is preferred"
  echo " "
else
  echo "[IPv6] IPv4 access is preferred" 
  echo " "
fi

# Default IP

ipaddr_config=$(grep '192.168.1.4' /etc/config/network)

if [ -z "$ipaddr_config" ]; then
  echo "[Default-IP] address is not the catwrt default 192.168.1.4"
  echo "Please configure your network at 'https://www.miaoer.xyz/posts/network/quickstart-catwrt'"
  echo " "
fi

# Bypass Gateway

wan_config=$(grep 'config interface' /etc/config/network | grep 'wan')

if [ -z "$wan_config" ]; then
  echo "[Bypass Gateway] No config for 'wan' interface found in /etc/config/network"
  echo "Please check if your device is set as a Bypass Gateway"
  echo " "
fi

# Rotuer Mode(PPPoE)

pass_config=$(grep 'password' /etc/config/network)
user_config=$(grep 'username' /etc/config/network)
pppoe_config=$(grep 'pppoe' /etc/config/network)

if [ -n "$pass_config" ] && [ -n "$user_config" ] && [ -n "$pppoe_config" ]; then
    echo "[PPPoE] PPPoE Rotuer Mode"
    echo " " 
else
    echo "[PPPoE] DHCP protocol detected in WAN interface"
    echo "The device may not be in PPPoE Rotuer Mode"
    echo " " 
fi

# IPv6 WAN6

grep 'config interface' /etc/config/network | grep 'wan6'  > /dev/null
if [ $? -ne 0 ]; then
   echo "[wan6] Your IPv6 network may have issues"
   echo " "
fi 

grep 'dhcpv6' /etc/config/network > /dev/null
if [ $? -ne 0 ]; then
   echo "[wan6] Your IPv6 network may have issues"
   echo " "
fi

# Tcping

echo "[Tcping] Testing..."

tcping -q -c 1 cn.bing.com
[ $? -ne 0 ] && echo "Failed: cn.bing.com"

tcping -q -c 1 bilibili.com
[ $? -ne 0 ] && echo "Failed: bilibili.com"

tcping -q -c 1 github.com
[ $? -ne 0 ] && echo "Failed: github.com"

tcping -q -c 1 google.com.hk
[ $? -ne 0 ] && echo "Failed: google.com.hk"

echo " "
echo "$(date) - Network check completed"
echo " "
echo "CatWrt Network Diagnostics by @miaoermua"
echo " "
echo " "
echo " "
