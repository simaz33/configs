#!/usr/bin/sh

# Determine battery count
BAT_count=$(ls /sys/class/power_supply/ | grep BAT* | wc -l)

# Get all battery capacities and divide by battery count
BAT_prcnt=$(($(cat /sys/class/power_supply/BAT*/capacity | awk '{prcnt += $1} END {print prcnt}') / $BAT_count))

# Get battery states and display them in one line
BAT_state=$(cat /sys/class/power_supply/BAT*/status | tr '[:upper:]' '[:lower:]')
BAT_state=$(echo $BAT_state | tr -d '\n')

# Determine what state to display
case $BAT_state in
	*discharging*)
		BAT_state="BATR"
		;;
	full*full | full*unknown)
		BAT_state="FULL"
		;;
	*charging*)
		BAT_state="CHRG"
		;;
	*)
		BAT_state="UNKW"
		;;
esac

# Full text
echo "$BAT_state $BAT_prcnt%"

# Short text (empty because the format is already short)
echo

# If battery percent is greater then 70% it is displayed as green, between 70% and 20% - yellow, equal or less than 20% - red
[ $BAT_prcnt -gt 70 ] && echo \#00FF00
[ $BAT_prcnt -le 70 ] && [ $BAT_prcnt -gt 20 ] && echo \#FFFF00
[ $BAT_prcnt -le 20 ] && echo \#FF0000
