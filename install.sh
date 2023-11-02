# Holy fuck this is like entirely AI-generated.
#!/bin/bash

sudo timedatectl set-local-rtc 1 --adjust-system-clock

# Add Defaults timestamp_timeout=60 to sudoers.d file timeout
echo 'Defaults timestamp_timeout=60' | sudo tee -a /etc/sudoers.d/defaults

# Replace line that contains 'ParallelDownloads' in pacman.conf with 'ParallelDownloads = 10'
sudo sed -i '/ParallelDownloads/c\ParallelDownloads = 10' /etc/pacman.conf

# Copy .bashrc to $HOME
cp Misc/.bashrc ~

# Add Chaotic-AUR
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Add Chaotic-AUR to pacman.conf
echo '[chaotic-aur]' | sudo tee -a /etc/pacman.conf
echo 'Include = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf

sudo pacman -Syyu

# Install packages noconfirm and needed from packages.txt
sudo pacman -S --noconfirm --needed - < packages.txt

# Install AUR packages noconfirm and needed from aurpackages.txt
yay -S --noconfirm --needed - < aurpackages.txt

#Install fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# Catppuccin GTK
git clone --recurse-submodules https://github.com/catppuccin/gtk
cd gtk
virtualenv -p python3 venv
source venv/bin/activate
pip install -r requirements.txt
python install.py mocha -a yellow -l
cd ..
rm -rf gtk

# Copy files from Configs to ~/.config
cp -r Configs/* ~/.config

if [ ! -f "~/.config/kdeglobals" ]; then
    # Create the file if it doesn't exist
    touch "~/.config/kdeglobals"
    
    # Print [General] and TerminalApplication=kitty in the file
    echo "[General]" >> "~/.config/kdeglobals"
    echo "TerminalApplication=kitty" >> "~/.config/kdeglobals"
fi
if [ -f "~/.config/kdeglobals" ]; then
    sed -i '/\[General\]/a TerminalApplication=kitty' "~/.config/kdeglobals"
fi

# Copy Misc/konsole/ to ~/.local/share/konsole/
cp -r Misc/konsole/ ~/.local/share

# Install fonts from Fonts
sudo cp -r Fonts/* /usr/share/fonts

# Copy argv.json to $HOME/.vscode (create dir if not exist)
mkdir -p ~/.vscode
cp Misc/argv.json ~/.vscode

# Git clone https://github.com/GhostNaN/mpvpaper and reset to commit f65700a
git clone https://github.com/GhostNaN/mpvpaper
cd mpvpaper
git reset --hard f65700a
meson build --prefix=/usr/local
ninja -C build
sudo ninja -C build install
cd ..
rm -rf mpvpaper

# Enable idlehack on startup
systemctl --user enable idlehack
systemctl --user start idlehack

# Install rEFInd
refind-install

# Change timeout 20 (exact match) to timeout 10
sudo sed -i '/timeout 20/c\timeout 10' /boot/efi/EFI/refind/refind.conf
# Uncomment 'default_selection Microsoft'
sudo sed -i '/default_selection Microsoft/c\default_selection Microsoft' /boot/efi/EFI/refind/refind.conf
# Download rEFInd theme (create dir if not exist)
sudo mkdir -p /boot/efi/EFI/refind/themes
# git clone theme to /boot/efi/EFI/refind/themes
sudo git clone https://github.com/bushtail/refind-efifetch ~/.config/refind/themes

# Replace line hosts: mymachines in /etc/nsswitch.conf with hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns
sudo sed -i '/hosts: mymachines/c\hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns' /etc/nsswitch.conf

# Append XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots" to ~/.config/user-dirs.dirs
mkdir -p ~/Pictures/Screenshots
echo 'XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"' | sudo tee -a ~/.config/user-dirs.dirs

# Enable SDDM at startup
sudo systemctl enable sddm