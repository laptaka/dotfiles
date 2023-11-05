# Holy fuck this is like entirely AI-generated.
#!/bin/bash

exec > >(tee myfile.log) 2>&1

clear
# Check if yay is installed, install yay and dependencies if not
if ! command -v yay &> /dev/null
then
    echo "Log: yay not found, installing yay"
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
fi


clear
# Make the user choose between a minimal and full install. Run Scripts/minimal.sh if minimal and Scripts/full.sh if full.
# If any other input is given, make user choose again
choice=""
while [[ "$choice" != "m" && "$choice" != "M" && "$choice" != "f" && "$choice" != "F" ]]; do
    echo "Choose between a minimal (M) and full (f) install:"
    read -r choice
    echo

    case "$choice" in
        m|M)
            # Run minimal.sh script
            ./Scripts/minimal.sh
            ;;
        f|F)
            # Run full.sh script
            ./Scripts/full.sh
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done


clear
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
    touch ~/.config/kdeglobals
    
    # Print [General] and TerminalApplication=kitty in the file
    echo "[General]" >> ~/.config/kdeglobals
    echo "TerminalApplication=kitty" >> ~/.config/kdeglobals
fi
if [ -f "~/.config/kdeglobals" ]; then
    sed -i '/\[General\]/a TerminalApplication=kitty' "~/.config/kdeglobals"
fi

# Copy Misc/konsole/ to ~/.local/share/konsole/
cp -r Misc/konsole/ ~/.local/share

# Install fonts from Fonts
sudo cp -r Fonts/* /usr/share/fonts

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

sudo systemctl enable --now swayosd-libinput-backend.service

# Append XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots" to ~/.config/user-dirs.dirs
mkdir -p ~/Pictures/Screenshots
echo 'XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"' | tee -a ~/.config/user-dirs.dirs

# Enable SDDM at startup
sudo systemctl enable sddm

# Copy sddm.conf to /etc/sddm.conf.d (create dir if not exist)
sudo mkdir -p /etc/sddm.conf.d
sudo cp Misc/sddm.conf /etc/sddm.conf.d/

# Copy .directory file to ~/.local/share/dolphin/view_properties/global/
mkdir -p ~/.local/share/dolphin/view_properties/global/
cp Misc/.directory ~/.local/share/dolphin/view_properties/global/

# Copy nwg-look folder to ~/.local/share/
cp -r Misc/nwg-look/ ~/.local/share/