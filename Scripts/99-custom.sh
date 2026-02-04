#!/bin/bash

# Beware! This script will be in /rom/etc/uci-defaults/ as part of the image.
# Uncomment lines to apply:
#
wlan_name="ImmortalWrt"
wlan_password="1234567890"
#
wlan_name_5g="ImmortalWrt-5G"
wlan_password_5g="123456789"
#
root_password="password"
lan_ip_address="192.168.2.1"

# log potential errors
exec >/tmp/setup.log 2>&1

[ "$(uci -q get wireless.@wifi-iface[0].ssid)" = "$wlan_name" ] && exit 0

if [ -n "$root_password" ]; then
  (echo "$root_password"; sleep 1; echo "$root_password") | passwd > /dev/null
fi

# Configure LAN
# More options: https://openwrt.org/docs/guide-user/base-system/basic-networking
if [ -n "$lan_ip_address" ]; then
  uci set network.lan.ipaddr="$lan_ip_address"
  uci commit network
fi

# Configure WLAN2.4G
# More options: https://openwrt.org/docs/guide-user/network/wifi/basic#wi-fi_interfaces
if [ -n "$wlan_name" -a -n "$wlan_password" -a ${#wlan_password} -ge 8 ]; then
  uci set wireless.@wifi-device[0].disabled='0'
  uci set wireless.@wifi-iface[0].disabled='0'
  uci set wireless.@wifi-iface[0].encryption='psk2'
  uci set wireless.@wifi-iface[0].ssid="$wlan_name"
  uci set wireless.@wifi-iface[0].key="$wlan_password"
  uci set wireless.@wifi-iface[0].ieee80211r='1'
  uci commit wireless
fi

# Configure WLAN5G
# More options: https://openwrt.org/docs/guide-user/network/wifi/basic#wi-fi_interfaces
if [ -n "$wlan_name_5g" -a -n "$wlan_password_5g" -a ${#wlan_password_5g} -ge 8 ]; then
  uci set wireless.@wifi-device[1].disabled='0'
  uci set wireless.@wifi-iface[1].disabled='0'
  uci set wireless.@wifi-iface[1].encryption='sae'
  uci set wireless.@wifi-iface[1].ssid="$wlan_name_5g"
  uci set wireless.@wifi-iface[1].key="$wlan_password_5g"
  uci set wireless.@wifi-iface[1].ieee80211r='1'
  uci commit wireless
fi

# Configure PPPoE
# More options: https://openwrt.org/docs/guide-user/network/wan/wan_interface_protocols#protocol_pppoe_ppp_over_ethernet
if [ -n "$pppoe_username" -a "$pppoe_password" ]; then
  uci del network.wan6
  uci set network.wan.proto='pppoe'
  uci set network.wan.username="$pppoe_username"
  uci set network.wan.password="$pppoe_password"
  uci set network.wan.ipv6='auto'
  uci commit network
fi
# Configure
# More options: https://openwrt.org/docs/guide-user/network/network_configuration?s[]=globals&s[]=packet&s[]=steering#section_globals

uci set network.globals.ula_prefix='fd00::/8'
uci set turboacc.config.tcpcca='bbr'

echo "All done!"
