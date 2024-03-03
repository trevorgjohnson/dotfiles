#!/bin/bash

# Updates the list of environment variables used by the dbus-daemon
echo "Updating the list of environment variables..."
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Kill any existing portals
echo "Killing existing portals..."
sleep 4
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal

# Set up portals
echo "Setting up portals..."
sleep 4
systemctl --user start xdg-desktop-portal-hyprland
systemctl --user start xdg-desktop-portal

# Start Waybar (status bar) and Hyprpaper (wallpaper manager)
echo "Starting Waybar and Hyprpaper..."
/usr/bin/waybar &
/usr/bin/hyprpaper &

echo "Hyprland was set up successfully!"
