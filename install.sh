install_aur() {
    local package="$1"

    # Check if the package is already installed
    if yay -Qs "$package" >/dev/null 2>&1; then
        echo "[-] AUR package $package is already installed"
    else
        echo "[+] Installing AUR package $package"
        yay -S --noconfirm --needed "$package"
    fi
}

install(){
	local package="$1"
	if sudo pacman -Qs "$package" > /dev/null 2>&1; then
		echo "[-] pacman package $package is already installed"
	else
		echo "[+] Installing $package"
		sudo pacman -S --noconfirm --needed $package
	fi
}

install_nerdfonts() {
    local font_dir="$HOME/.local/share/fonts"

    # Check if Nerd Fonts are already installed
    if fc-list | grep -i "nerd font" >/dev/null; then
        echo "[-] Nerd Fonts are already installed"
    else
        echo "[+] Installing Nerd Fonts"

        # Create the fonts directory if it doesn't exist
        mkdir -p "$font_dir"

        # Download and extract Hack Nerd Font
        wget -O Hack.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip"
        unzip Hack.zip -d Hack_Font

        # Copy the .ttf files to the fonts directory
        find Hack_Font -name '*.ttf' -exec cp {} "$font_dir/" \;

        # Clean up the extracted files
        rm -rf Hack_Font Hack.zip

        # Update the font cache
        fc-cache -f -v
    fi
}


install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "[*] Oh My Zsh is already installed"
    	zshrc_customizations
    else
        echo "[-] Oh My Zsh is not installed. Installing..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	echo "[*] Oh My Zsh has been installed"
    fi
}

zshrc_customizations() {
    local zshrc_path="$HOME/.zshrc"

    # Check if autosuggestions are already added
    if ! grep -q "zsh-autosuggestions.zsh" "$zshrc_path"; then
        echo "[+] Adding autosuggestions"
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
        echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$zshrc_path"
    else
        echo "[-] Autosuggestions are already added"
    fi

    # Check if ls alias is already added
    if ! grep -q "alias ls=\"exa --group-directories-first --icons -m\"" "$zshrc_path"; then
        echo "[+] Adding ls alias"
        echo "alias ls=\"exa --group-directories-first --icons -m\"" >> "$zshrc_path"
    else
        echo "[-] ls alias is already added"
    fi

    # Check if cat alias is already added
    if ! grep -q "alias cat=\"/usr/bin/bat --paging=never --theme=ansi\"" "$zshrc_path"; then
        echo "[+] Adding cat alias"
        echo "alias cat=\"/usr/bin/bat --paging=never --theme=ansi\"" >> "$zshrc_path"
    else
        echo "[-] cat alias is already added"
    fi

    # Check if catnl alias is already added
    if ! grep -q "alias catnl=\"/usr/bin/cat\"" "$zshrc_path"; then
        echo "[+] Adding catnl alias"
        echo "alias catnl=\"/usr/bin/cat\"" >> "$zshrc_path"
    else
        echo "[-] catnl alias is already added"
    fi

    # Check if PATH modifications are already added
    if ! grep -q "/home/p4n/.local/bin" "$zshrc_path"; then
        echo "[+] Adding PATH modifications"
        echo 'export PATH="/home/p4n/.local/bin:$PATH"' >> "$zshrc_path"
        echo 'export PATH="/home/p4n/go/bin:$PATH"' >> "$zshrc_path"
    else
        echo "[-] PATH modifications are already added"
    fi

    # Check if curlie alias is already added
    if ! grep -q "alias curl=\"/home/p4n/go/bin/curlie\"" "$zshrc_path"; then
        echo "[+] Adding curlie alias"
        echo "alias curl=\"/home/p4n/go/bin/curlie\"" >> "$zshrc_path"
    else
        echo "[-] curlie alias is already added"
    fi

    # Check if fzf is already installed
    if [ ! -d "$HOME/.fzf" ]; then
        echo "[+] Installing fzf"
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install"
    else
        echo "[-] fzf is already installed"
    fi
}

function config_alacritty(){
    if [ ! -d "$HOME/.config/alacritty" ]; then
        echo "[+] Ricing alacritty"
	mkdir -p $HOME/.config/alacritty
	cp ./alacritty/alacritty.yml $HOME/.config/alacritty/
    else
        echo "[-] Alacritty conf exists"
    fi
}

config_i3() {
    local i3_config_path="$HOME/.config/i3/config"

    # Check if i3 configurations are already modified
    if grep -q "i3-gaps" "$i3_config_path" && grep -q "flameshot" "$i3_config_path"; then
        echo "[-] i3 configurations are already modified"
    else
        echo "[+] Modifying i3 configurations"
	echo 'exec_always --no-startup-id autotiling' >> ~/.config/i3/config
        # Modify keybindings
        sed -i 's/bindsym $mod+Shift+q kill/bindsym $mod+q kill/' "$i3_config_path"
        sed -i 's/bindsym $mod+Return exec i3-sensible-terminal/bindsym $mod+Return exec alacritty/' "$i3_config_path"
	sed -i 's/bindsym $mod+d exec --no-startup-id dmenu_run/bindsym $mod+d exec --no-startup-id rofi' "$i3_config_path"
        # Append additional configurations
        cat << EOF >> "$i3_config_path"

# i3-gaps
smart_borders on
for_window [class="^.*"] border pixel 1
gaps inner 10
gaps outer 5

# class                 border  backgr. text    indicator child_border
client.focused          #e345c1 #e345c1 #e345c1 #e345c1   #e345c1
client.focused_inactive #2d0d26 #2d0d26 #2d0d26 #2d0d26   #2d0d26
client.unfocused        #2d0d26 #2d0d26 #2d0d26 #2d0d26   #2d0d26

# flameshot
bindsym Print exec flameshot gui
EOF
    fi
}

function setwallpaper(){
    mkdir -p $HOME/wallpaper
    cp ./wallpaper/bg.jpg $HOME/wallpaper/
    #echo 'exec --no-startup-id feh --bg-scale /home/p4n/wallpaper/bg.jpg' >> ~/.config/i3/config
    if grep -q "exec --no-startup-id feh --bg-scale /home/p4n/wallpaper/bg.jpg" ~/.config/i3/config; then
        echo "[-] Wallpaper config exists"
    else
        echo 'exec --no-startup-id feh --bg-scale /home/p4n/wallpaper/bg.jpg' >> ~/.config/i3/config
    fi
}

unzip_neonkawaii_theme() {
    local source_file="./gtk/neonkawaii_gtk.zip"
    local destination_dir="$HOME/.themes/neonkawaii"

    # Create the destination directory if it doesn't exist
    mkdir -p "$destination_dir"

    # Unzip the file to the destination directory
    unzip "$source_file" -d "$destination_dir"
}

unzip_neonkawaii_icons() {
    local source_file="./gtk/neonkawaii_icons.zip"
    local destination_dir="$HOME/.icons/neonkawaii"

    # Create the destination directory if it doesn't exist
    mkdir -p "$destination_dir"

    # Unzip the file to the destination directory
    unzip "$source_file" -d "$destination_dir"
}

setup_rofi() {
    local i3_config_path="$HOME/.config/i3/config"
    if grep -q "bindsym \$mod+d exec --no-startup-id rofi -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/menu.rasi" "$i3_config_path"; then
        echo "[-] Rofi configuration exists"
    else
        echo "[+] Modifying Rofi configuration"
	mkdir -p ~/.config/rofi
	cp ./rofi/menu.rasi ~/.config/rofi
        sed -i 's/bindsym Mod1+d exec --no-startup-id dmenu_run/bindsym $mod+d exec --no-startup-id rofi -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/menu.rasi/' "$i3_config_path"
    fi
}


install_aur vim
install_aur autotiling
install_aur alacritty
install_aur zsh
install_aur exa
install_aur bat
install_aur go
install_aur xclip
install_aur python-pip
install_aur feh
install_aur flameshot
install_aur rofi
install_nerdfonts
install i3-wm

config_alacritty
config_i3
zshrc_customizations
setwallpaper
#unzip_neonkawaii_theme -> uncomment when its done
#unzip_neonkawaii_icons -> uncomment when its done
setup_rofi
