#!/bin/bash
# Holy fuck this is like entirely AI-generated.

exec > >(tee log.log) 2>&1

clear
# Check if yay is installed, install yay and dependencies if not
if ! command -v yay &>/dev/null; then
    echo "Log: yay not found, installing yay"
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si
    cd ..
    rm -rf yay
fi

# Define a function named nvidia_detect
nvidia_detect() {
    # Check if the output of lspci -k command contains "VGA" or "3D" and "nvidia"
    # The lspci -k command lists all PCI devices and their drivers
    # The grep -A 2 -E "(VGA|3D)" command searches for "VGA" or "3D" in the output of lspci -k and prints the next two lines
    # The grep -i nvidia command searches for "nvidia" in the output of the previous grep command, ignoring case
    # The wc -l command counts the number of lines in the output of the previous grep command
    # If the number of lines is greater than 0, it means that an NVIDIA VGA or 3D device is detected
    if [ "$(lspci -k | grep -A 2 -E '(VGA|3D)' | grep -ci nvidia)" -gt 0 ]; then
        # If an NVIDIA VGA or 3D device is detected, the function returns 0, indicating success
        echo "Log: Nvidia card detected"
        return 0
    else
        # If no NVIDIA VGA or 3D device is detected, the function returns 1, indicating failure
        echo "Log: No Nvidia card detected"
        return 1
    fi
}

# If nvidia_detect function is true, install nvidia packages
if nvidia_detect; then
    echo "Log: Adding nvidia packages"
    echo -e "\nnvidia-dkms\nnvidia-utils\nnvitop" >>packages.txt
    # replace hyprland with hyprland-nvidia
    sed -i "s/^hyprland/hyprland-nvidia/g" packages.txt
else
    echo "Log: Skipping adding nvidia packages"
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
    m | M)
        # Run minimal.sh script
        ./Scripts/minimal.sh
        ;;
    f | F)
        # Run full.sh script
        ./Scripts/full.sh
        ;;
    *)
        echo "Invalid choice. Please try again."
        ;;
    esac
done

# Add nvidia.conf to ~/.config/hypr/hyprland.conf
if nvidia_detect; then
    echo -e 'source = ~/.config/hypr/nvidia.conf \n' >>${HOME}/.config/hypr/hyprland.conf
fi

# Catppuccin GTK (not sure if needed)
echo "Log: Installing Catppuccin GTK"
git clone --recurse-submodules https://github.com/catppuccin/gtk
cd gtk || exit
virtualenv -p python3 venv
# shellcheck disable=SC1091
source venv/bin/activate
pip install -r requirements.txt
python install.py mocha -a yellow -l
cd ..
rm -rf gtk

# Copy files from Configs to ~/.config
echo "Log: Copying files from Configs to ~/.config"
cp -r Configs/* ~/.config

echo "Log: Adding terminal config to ~/.config/kdeglobals"
if [ ! -f "$HOME/.config/kdeglobals" ]; then
    # Create the file if it doesn't exist
    echo "Log: Creating ~/.config/kdeglobals"
    touch ~/.config/kdeglobals

    # Print [General] and TerminalApplication=kitty in the file
    echo "Log: Adding TerminalApplication=kitty to ~/.config/kdeglobals"
    echo "[General]" >>~/.config/kdeglobals
    echo "TerminalApplication=kitty" >>~/.config/kdeglobals
fi
if [ -f "$HOME/.config/kdeglobals" ]; then
    echo "Log: Adding TerminalApplication=kitty to ~/.config/kdeglobals"
    sed -i '/\[General\]/a TerminalApplication=kitty' "$HOME/.config/kdeglobals"
fi

# Copy Misc/konsole/ to ~/.local/share/konsole/
echo "Log: Copying Misc/konsole/ to ~/.local/share/konsole/"
cp -r Misc/konsole/ ~/.local/share

# Install fonts from Fonts
echo "Log: Installing fonts from Fonts"
sudo cp -r Fonts/* /usr/share/fonts

# Git clone https://github.com/GhostNaN/mpvpaper and reset to commit f65700a
echo "Log: Installing mpvpaper"
git clone https://github.com/GhostNaN/mpvpaper
cd mpvpaper || exit
git reset --hard f65700a
meson build --prefix=/usr/local
ninja -C build
sudo ninja -C build install
cd ..
rm -rf mpvpaper

# Enable idlehack on startup
echo "Log: Enabling idlehack on startup"
systemctl --user enable --now idlehack

# Enable SwayOSD on startup
echo "Log: Enabling SwayOSD on startup"
sudo systemctl enable --now swayosd-libinput-backend.service

# Append XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots" to ~/.config/user-dirs.dirs
echo "Log: Adding XDG_SCREENSHOTS_DIR to ~/.config/user-dirs.dirs"
mkdir -p ~/Pictures/Screenshots
# shellcheck disable=SC2016
echo 'XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"' | tee -a ~/.config/user-dirs.dirs

# Copy sddm.conf to /etc/sddm.conf.d (create dir if not exist)
echo "Log: Copying sddm.conf to /etc/sddm.conf.d"
sudo mkdir -p /etc/sddm.conf.d
sudo cp Misc/sddm.conf /etc/sddm.conf.d/

# Copy Misc/dolphin folder to ~/.local/share/
echo "Log: Copying Misc/dolphin folder to ~/.local/share/"
cp -r Misc/dolphin/ ~/.local/share/

# Copy nwg-look folder to ~/.local/share/
echo "Log: Copying nwg-look folder to ~/.local/share/"
cp -r Misc/nwg-look/ ~/.local/share/
nwg-look -a

# Enable SDDM at startup now
echo "Log: Enabling SDDM now"
sudo systemctl enable --now sddm
