#!/bin/bash

# Install packages
echo "Log: Installing packages"
yay -S --noconfirm --needed - <packages.txt
