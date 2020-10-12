#!/usr/bin/sh

curr_vol=$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')

if [[ $curr_vol -lt 120 ]]
then
	 pactl set-sink-volume @DEFAULT_SINK@ +5%
fi
