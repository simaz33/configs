#!/usr/bin/sh

cities=$1
cities_tmp=~/.config/i3/cities_tmp
touch $cities_tmp
chmod 666 $cities_tmp

city=$(cat $cities | head -1)
tail -n +2 $cities > $cities_tmp && mv $cities_tmp $cities && echo $city >> $cities

response=$(curl -Ss https://wttr.in/$city?0T)

[ !$response ] && echo "Wttr is down" && echo && echo \#797979 && exit

weat=$(echo "$response" | head -3 | tail -1 | cut -b 17-)
temp=$(echo "$response" | head -4 | tail -1 | cut -b 17- | cut -d 'C' -f 1)C
color=""

# Check if city exist
[ $(echo "$response" | tail -6 | grep unable) ] && echo "$city not found" && echo && echo \#797979 && exit

temp_nrs=$(echo $temp | cut -d ' ' -f 1)
avg_temp=$((($(echo $temp_nrs | cut -d '.' -f 1) + $(echo $temp_nrs | cut -d '.' -f 3)) / 2))

case $avg_temp in
    3[5-9])
        color=\#FFA500
        ;;
    3[0-4])
        color=\#FFFF00
        ;;
    2[5-9])
        color=\#B2FF66
        ;;
    2[0-4])
        color=\#00CC00
        ;;
    1[5-9])
        color=\#00FFFF
        ;;
    1[0-4])
        color=\#66B2FF
        ;;
    [5-9])
        color=\#0080FF
        ;;
    [0-4])
        color=\#0000FF
        ;;
    -[1-4])
        color=\#000099
        ;;
    -[0-9]*)
        color=\#6600CC
        ;;
    [0-9]*)
        color=\#FF0000
        ;;
esac

# Full text
echo "$city, $weat $temp"

# Short text
echo

# Color
echo $color
