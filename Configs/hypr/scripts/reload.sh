#!/usr/bin/env sh
 
hyprctl reload
killall waybar
waybar & disown