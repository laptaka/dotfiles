#!/bin/bash


# Add Defaults timestamp_timeout=10 to sudoers.d file timeout
echo 'Log: Writing timestamp_timeout=10 to /etc/sudoers.d/defaults'
echo 'Defaults timestamp_timeout=10' | sudo tee -a /etc/sudoers.d/defaults
echo 'Log: Wrote timestamp_timeout=10 to /etc/sudoers.d/defaults'

sudo echo "Log: Setting local RTC to 1 and adjusting system clock..."
sudo timedatectl set-local-rtc 1 --adjust-system-clock
sudo echo "Log: Local RTC set to 1 and system clock adjusted successfully."

# Replace line that contains 'ParallelDownloads' in pacman.conf with 'ParallelDownloads = 10'
sudo sed -i '/ParallelDownloads/c\ParallelDownloads = 10' /etc/pacman.conf
echo "Log: ParallelDownloads set to 10"


# Install reflector
echo "Log: Installing reflector"
sudo pacman -S --needed --noconfirm reflector

# Replace sort by age with sort by rate in reflector.conf
echo "Log: Replacing sort by age with sort by rate in reflector.conf"
sudo sed -i '/--sort age/c\--sort rate' /etc/xdg/reflector/reflector.conf
sudo systemctl enable reflector.timer
sudo systemctl start reflector.service


# Add Chaotic-AUR
echo "Log: Adding Chaotic-AUR to pacman keyring"
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Add Chaotic-AUR to pacman.conf
echo "Log: Adding Chaotic-AUR to pacman.conf"
echo -e '\n[chaotic-aur]' | sudo tee -a /etc/pacman.conf
echo 'Include = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf

# Update the package database and upgrade all installed packages
echo "Log: Updating the package database and upgrading all installed packages"
sudo pacman --noconfirm -Syyu


# Install fish
echo "Log: Installing fish"
sudo pacman -S --noconfirm --needed fish
cp Misc/.bashrc ~

# Install fisher
echo "Log: Installing fisher"
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"


echo "Log: Adding lines from fullinstall.txt to packages.txt"
cat Misc/fullinstall.txt >> packages.txt

# Install packages
echo "Log: Installing packages (full)"
yay -S --noconfirm --needed - < packages.txt


# Copy argv.json to $HOME/.vscode (create dir if not exist)
echo "Log: Copying argv.json to $HOME/.vscode"
mkdir -p ~/.vscode
cp Misc/argv.json ~/.vscode

# Spicetify prep
echo "Log: Spicetify prep chmod"
sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

# Add games group
echo "Log: Adding games group"
sudo usermod -a -G games $USER

# Change timeout 20 (exact match) to timeout 10
echo "Log: Changing timeout 20 to timeout 10 in refinf.conf"
sudo sed -i '/timeout 20/c\timeout 10' /boot/efi/EFI/refind/refind.conf
# Uncomment 'default_selection Microsoft'
echo "Log: Uncommenting default_selection Microsoft in refinf.conf"
sudo sed -i '/default_selection Microsoft/c\default_selection Microsoft' /boot/efi/EFI/refind/refind.conf
# Uncomment use_graphics_for
echo "Log: Setting use_graphics_for linux in refinf.conf"
sudo sed -i '/use_graphics_for/c\use_graphics_for linux' /boot/efi/EFI/refind/refind.conf
# Download rEFInd theme (create dir if not exist)
echo "Log: Downloading rEFInd theme"
sudo mkdir -p /boot/efi/EFI/refind/themes
# git clone theme to /boot/efi/EFI/refind/themes
sudo git clone https://github.com/bushtail/refind-efifetch ~/.config/refind/themes