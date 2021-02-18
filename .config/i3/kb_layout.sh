#!/usr/bin/sh
# change_kb_layout

kb_layout=$(xset -q | grep LED | awk '{print $10}')

case "$kb_layout" in
    "00000000")
        kb_layout="EN"
        ;;
        
    "00001000")
        kb_layout="LT"
        ;;  

    *)
        kb_layout="??"
        ;;
esac

#Full text
echo $kb_layout

#Short text
echo "" 

#Text color
echo \#FFFFFF
