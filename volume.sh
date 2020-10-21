#!/usr/bin/sh

muted=$(pactl list sinks | grep '^[[:space:]]Mute:' | awk '{print $2}')
curr_vol=''
color=''

if [[ $muted == yes ]]
then
	curr_vol="MUT"
	color=\#FFA500
else
	curr_vol=$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')%
	color=\#FFFFFF	
fi	

echo "VOL $curr_vol"
echo
echo $color
