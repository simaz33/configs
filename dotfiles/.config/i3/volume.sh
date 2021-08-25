#!/usr/bin/sh
# change_volume

muted=$(pacmd list-sinks | grep -A 11 \* | tail -1 | cut -d ' ' -f 2)
volume=''
max_vol=$(cat ~/.config/i3/inc_vol.sh | grep -i max_vol | head -n 1 | cut -d '=' -f 2)
volume_symbol=''
color=''
image=''

if [[ $muted == yes ]]
then
    volume_symbol="\uf6a9"
    color=\#FFA500
    image=~/.config/i3/volume_mute.png
else
	volume=$(pacmd list-sinks | grep -A 7 \* | tail -1 | cut -d '/' -f2 | tr -d ' %')
    if [[ $volume -ge 90 ]]
    then
        volume_symbol="\uf028"
        image=~/.config/i3/volume_high.png 
    elif [[ $volume -ge 50 ]]
    then
        volume_symbol="\uf027"
        image=~/.config/i3/volume_medium.png
    elif [[ $volume -gt 0 ]]
    then
        volume_symbol="\uf027"
        image=~/.config/i3/volume_low.png
    else
        volume_symbol="\uf026"
        image=~/.config/i3/volume_mute.png
    fi
    color=\#FFFFFF	
fi	

# Full text
echo -e "$volume_symbol $volume"

# Short text
echo

# Color
echo $color
