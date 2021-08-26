#!/usr/bin/sh

name=$(bluetooth | awk '{print $3}')
color=\#797979
bluetooth_symbol="\uf294"

if [[ $name = off ]]
then
	name="OFF"
else
	#status="ON"
	name=$(bluetoothctl info | grep Alias | cut -b 9-)
	
	if [[ $name ]]
	then
		color=\#00FF00
	else
		name="ON"
		color=\#FFFF00
	fi
fi

# Full text
echo -e "$bluetooth_symbol $name"

# Short text
echo

# Color of text
echo $color
