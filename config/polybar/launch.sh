#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
#polybar-msg cmd quit

# Launch bar1 and bar2
echo "---" | tee -a /tmp/mybar.log
polybar mybar 2>&1 | tee -a /tmp/mybar.log & disown
polybar mybar2 2>&1 | tee -a /tmp/mybar2.log & disown

#echo "Bars launched..."
#
#if type "xrandr"; then
#  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#    MONITOR=$m polybar --reload example &
#  done
#else
#  polybar --reload example &
#fi
