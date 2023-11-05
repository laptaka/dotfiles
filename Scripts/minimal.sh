#!/bin/bash

# Nvidia
if nvidia_detect ; then
    echo "Log: Installing nvidia packages"
    echo -e "nvidia-dkms\nnvidia-utils" >>packages.txt
    # replace hyprland with hyprland-nvidia
    sed -i "s/^hyprland/hyprland-nvidia/g" packages.txt
else
    echo "Log: Skipping nvidia packages"
fi

# Install packages
echo "Log: Installing packages"
yay -S --noconfirm --needed - < packages.txt