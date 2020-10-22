#!/usr/bin/sh

city="Kaunas"
weat=$(curl -Ss https://wttr.in/$city?0T | tac | tac | head -3 | tail -1 | awk '{print $2, $3}' | tr -d ',')
temp=$(curl -Ss https://wttr.in/$city?0T | tac | tac | head -4 | tail -1 | awk '{print $3 $4}')

# Check if city exist
[ $(curl -s https://wttr.in/$city?0T | tail -6 | grep unable) ] && echo "NO WEATHER" && echo && echo \#FF0000 && exit

# Full text
echo "$city, $weat $temp"

# Short text
echo

# Color
echo \#FFFFFF
