#!/usr/bin/sh

volume=$(pacmd list-sinks | grep -A 7 \* | tail -1 | cut -d '/' -f2 | tr -d ' %')

if [[ $volume -lt 130 ]]
then
	 pactl set-sink-volume @DEFAULT_SINK@ +5%
fi
