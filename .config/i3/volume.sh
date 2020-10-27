#!/usr/bin/sh

muted=$(pacmd list-sinks | grep -A 11 \* | tail -1 | cut -d ' ' -f 2)
volume=''
color=''

if [[ $muted == yes ]]
then
	volume="MUT"
	color=\#FFA500
else
	volume=$(pacmd list-sinks | grep -A 7 \* | tail -1 | cut -d '/' -f2 | tr -d ' %')%
	color=\#FFFFFF	
fi	

# Full text
echo "VOL $volume"

# Short text
echo

# Color
echo $color
