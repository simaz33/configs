#!/usr/bin/sh

cities=$1
cities_tmp=~/.config/i3/cities_tmp
touch $cities_tmp
chmod 666 $cities_tmp

city=$(cat $cities | head -1)
tail -n +2 $cities > $cities_tmp && mv $cities_tmp $cities && echo $city >> $cities

weat=$(curl -Ss https://wttr.in/$city?0T | tac | tac | head -3 | tail -1 | cut -b 17-)
temp=$(curl -Ss https://wttr.in/$city?0T | tac | tac | head -4 | tail -1 | cut -b 17- | cut -d 'C' -f 1)C

# Check if city exist
[ $(curl -s https://wttr.in/$city?0T | tail -6 | grep unable) ] && echo "NO WEATHER" && echo && echo \#FF0000 && exit

# Full text
echo "$city, $weat $temp"

# Short text
echo

# Color
echo \#FFFFFF