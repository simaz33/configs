#!/usr/bin/sh

BAT_symbol=""
color=""

# Determine battery count
BAT_count=$(ls /sys/class/power_supply/ | grep BAT* | wc -l)

# Get all battery capacities and divide by battery count
BAT_prcnt=$(($(cat /sys/class/power_supply/BAT*/capacity | awk '{prcnt += $1} END {print prcnt}') / $BAT_count))

# Get battery states and display them in one line
BAT_state=$(cat /sys/class/power_supply/BAT*/status | tr '[:upper:]' '[:lower:]')
BAT_state=$(echo $BAT_state | tr -d '\n' | tr '[:upper:]' '[:lower:]')

# Determine what state to display
case $BAT_state in
	*discharging*)
		BAT_state=""
		;;
	full*full | full*unknown)
		BAT_state="\uf00c"
		;;
	*charging*)
		BAT_state="\uf0e7"
		;;
	*)
		BAT_state="\uf128"
		;;
esac

if [[ $BAT_prcnt -ge 75 ]]
then
    BAT_symbol="\uf240"
    color=\#00FF00
elif [[ $BAT_prcnt -ge 50 ]]
then
    BAT_symbol="\uf241"
    color=\#ADFF2F
elif [[ $BAT_prcnt -ge 25 ]] 
then
    BAT_symbol="\uf242"
    color=\#FFFF00
elif [[ $BAT_prcnt -ge 0 ]]
then
    BAT_symbol="\uf243"
    color=\#FF0000
else
    BAT_symbol="\uf244"
    color=\#FF0000
fi

# Full text
echo -e "$BAT_state $BAT_symbol $BAT_prcnt%"

# Short text (empty because the format is already short)
echo

# Color
echo $color
