#!/usr/bin/sh

# Check if a connection is established
is_connected=$(nmcli g | tail -1 | head -1 | awk '{print $1}')

[ $is_connected = disconnected ] && echo "W:(DOWN)" && echo && echo \#FF0000 && exit 

# Using NetworkManager interface to get wifi network name and signal strength
signal_ssid=$(nmcli c | head -2 | tail -1 | awk '{print $1}')
signal_strength=$(nmcli device wifi | grep "^*" | awk '{print $8}')

# Full text
[ $signal_ssid ] && echo "W:($signal_strength% $signal_ssid)"

# Short text
echo 

# Colors depending on signal strength
[ $signal_strength -ge 70 ] && echo \#00FF00 && exit 
[ $signal_strength -lt 70 ] && echo \#FFFF00 && exit
