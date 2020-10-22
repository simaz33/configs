#!/usr/bin/sh

# Using NetworkManager interface to get wifi network name and signal strength
signal_ssid=$(nmcli device wifi | grep "^*" | awk '{print $3}')
signal_strength=$(nmcli device wifi | grep "^*" | awk '{print $8}')

# Full text
[ $signal_ssid ] && echo "W:($signal_strength% $signal_ssid)"


# Short text
echo 

# Colors
[ $signal_strength -ge 70 ] && echo \#00FF00 && exit 
[ $signal_strength -lt 70 ] && echo \#FFFF00 && exit
