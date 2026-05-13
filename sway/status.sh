#!/bin/sh

battery() {
    cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null) || { printf ' '; return; }
    status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)

    if [ "$status" = "Charging" ]; then
        icon=""
    elif [ "$cap" -le 20 ]; then
        icon=""
    elif [ "$cap" -le 40 ]; then
        icon=""
    elif [ "$cap" -le 60 ]; then
        icon=""
    elif [ "$cap" -le 80 ]; then
        icon=""
    else
        icon=""
    fi

    printf '%s  %s%%' "$icon" "$cap"
}

while true; do
    printf '%s | %s' "$(battery)" "$(date +'%H:%M  %a %D')"
    sleep 1
done
