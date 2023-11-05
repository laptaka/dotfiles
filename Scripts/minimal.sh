#!/bin/bash

# Nvidia
read -p "You got green card (nvidia)? (Y/n): " -r asknvidia
echo
asknvidia=${asknvidia:-Y}
if [[ $asknvidia =~ ^[Yy]$ ]]; then
    echo "Log: Installing nvidia packages, installing hyprland-nvidia"
    yay -S --noconfirm --needed nvidia-dkms nvidia-utils hyprland-nvidia
else
    echo "Log: Skipping nvidia packages, installing hyprland"
    yay -S --noconfirm --needed hyprland
fi

# Install packages
echo "Log: Installing packages"
yay -S --noconfirm --needed - < ../packages.txt