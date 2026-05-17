#!/bin/sh

battery() {
    cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null) || { return; }
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
    battery=$(battery)
    if [ -z $battery ]; then
      printf '%s' "$(date +'%H:%M  %a %D')";
    else
      printf '%s | %s' "$battery" "$(date +'%H:%M  %a %D')";
    fi
    sleep 1
done
