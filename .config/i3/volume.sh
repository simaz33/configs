#!/usr/bin/sh

muted=$(pacmd list-sinks | grep -A 11 \* | tail -1 | cut -d ' ' -f 2)
volume=''
color=''

if [[ $muted == yes ]]
then
	volume="\uf6a9"
	color=\#FFA500
else
	volume=$(pacmd list-sinks | grep -A 7 \* | tail -1 | cut -d '/' -f2 | tr -d ' %')
    volume_symbol=""
    if [[ $volume -ge 75 ]]
    then
        volume_symbol="\uf028" 
    elif [[ $volume -lt 75 && $volume -ne 0 ]]
    then
        volume_symbol="\uf027"
    else
        volume_symbol="\uf026"
    fi
    volume="$volume_symbol $volume"
	color=\#FFFFFF	
fi	

# Full text
echo -e "$volume"

# Short text
echo

# Color
echo $color
