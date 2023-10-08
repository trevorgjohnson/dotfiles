#!/bin/bash

# Kill any existing portals
echo "Killing existing portals..."
sleep 1
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal

# Set up portals
echo "Setting up portals..."
/usr/lib/xdg-desktop-portal-hyprland & 
sleep 2 
/usr/lib/xdg-desktop-portal &

# Start Waybar (status bar) and Hyprpaper (wallpaper manager)
echo "Starting Waybar and Hyprpaper..."
/usr/bin/waybar &
/usr/bin/hyprpaper &

# Updates the list of environment variables used by the dbus-daemon
echo "Updating the list of environment variables..."
/usr/bin/dbus-update-activation-environment --systemd --all &

echo "Hyprland was set up successfully!"
