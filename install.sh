# Holy fuck this is like entirely AI-generated.
#!/bin/bash

# Add Defaults timestamp_timeout=60 to sudoers.d file timeout
echo 'Defaults timestamp_timeout=60' | sudo tee -a /etc/sudoers.d/defaults

# Replace line that contains 'ParallelDownloads' in pacman.conf with 'ParallelDownloads = 10'
sudo sed -i '/ParallelDownloads/c\ParallelDownloads = 10' /etc/pacman.conf

# Copy .bashrc to $HOME
cp Misc/.bashrc ~

# Add Chaotic-AUR
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Add Chaotic-AUR to pacman.conf
echo '[chaotic-aur]' | sudo tee -a /etc/pacman.conf
echo 'Include = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf

# Install packages noconfirm and needed from packages.txt
sudo pacman -S --noconfirm --needed - < packages.txt

# Install AUR packages noconfirm and needed from aurpackages.txt
yay -S --noconfirm --needed - < aurpackages.txt

#Install fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# Copy files from Configs to ~/.config
cp -r Configs/* ~/.config

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

# Catppuccin GTK
git clone --recurse-submodules https://github.com/catppuccin/gtk
cd gtk
virtualenv -p python3 venv
source venv/bin/activate
pip install -r requirements.txt
python install.py mocha -a yellow -l
cd ..
rm -rf gtk

# Catppuccin QT
git clone https://github.com/catppuccin/qt5ct
cd qt5ct
# Copy themes/Catppuccin-Mocha.conf to ~/.config/qt5ct/colors (create dir if not exist)
mkdir -p ~/.config/qt5ct/colors
cp themes/Catppuccin-Mocha.conf ~/.config/qt5ct/colors
cd ..
rm -rf qt5ct

# Enable idlehack on startup
sudo systemctl enable idlehack

# Add SDDM theme to sddm.conf.d (create file if not exist)
sudo touch /etc/sddm.conf.d/theme.conf
echo '[Theme]' | sudo tee -a /etc/sddm.conf.d/theme.conf
echo 'Current=sddm-slice' | sudo tee -a /etc/sddm.conf.d/theme.conf

# Install rEFInd
refind-install

# Enable SDDM at startup
sudo systemctl enable sddm