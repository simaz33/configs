#!/usr/bin/sh

# Check if wifi is on
name=$(wifi | cut -d '=' -f2 | cut -d ' ' -f2)
is_connected=""
signal_ssid=""
signal_strength=""

if [[ $name = off ]]
then
	name="OFF"
	color=\#797979
else
	# Check if a connection is established
	is_connected=$(nmcli g | tail -1 | head -1 | awk '{print $1}')
	if [[ $is_connected = disconnected ]]
	then
		name="ON"
		color=\#FFFF00
	else
		# Using NetworkManager interface to get wifi network name and signal strength
		signal_ssid=$(nmcli c | head -2 | tail -1 | awk '{print $1}')
		signal_strength=$(nmcli device wifi | grep "^*" | awk '{print $8}')
		color=\#00FF00
	fi
fi 



# Full text
if [[ $signal_ssid ]]
then
	echo "W:($signal_strength% $signal_ssid)"
else
	echo "W:($name)"
fi

# Short text
echo 

# Colors depending on signal strength
echo $color
