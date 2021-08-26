#!/bin/sh

cur_brightness=$(printf "%.0f\n" $(xbacklight))


dunstify -u low -t 1100 -I $HOME/.config/i3/brightness.png -r 5000 "$cur_brightness/100" 
