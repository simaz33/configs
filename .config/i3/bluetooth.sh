#!/usr/bin/sh

status=$(bluetooth | awk '{print $3}')
name=""
color=\#FF0000

if [[ $status = off ]]
then
	status="DOWN"
else
	status="UP"
	name=$(bluetoothctl info | grep Alias | cut -b 9-)
	
	if [[ $name ]]
	then
		color=\#00FF00
	else
		color=\#FFFF00
	fi
fi

# Full text
echo "BT:($status $name)"

# Short text
echo

# Color of text
echo $color
