#!/bin/bash
set -e

CONFIG_DIR="$PREFIX/etc/linux-on-android"
mkdir -p "$CONFIG_DIR"

menu() {
    echo "=== Linux on Android Manager ==="
    echo "1) Install a Linux distro"
    echo "2) Uninstall a specific distro"
    echo "3) Uninstall ALL distros"
    echo "4) Exit"
    read -p "Choose an option: " CHOICE

    case "$CHOICE" in
        1) install_linux ;;
        2) uninstall_one ;;
        3) uninstall_all ;;
        4) exit 0 ;;
        *) echo "Invalid choice"; menu ;;
    esac
}

install_linux() {
    apt update && apt upgrade -y

    if ! command -v proot-distro &> /dev/null; then
        apt install proot-distro -y
    fi

    echo "Available distros:"
    proot-distro list

    read -p "Enter distro to install (e.g., debian): " DISTRO
    read -p "Enter username to create: " USERNAME
    read -p "Install LXDE desktop? (y/N): " INSTALL_GUI
    read -p "VNC resolution (default 1920x1080): " RES
    RES=${RES:-1920x1080}

    echo "Installing $DISTRO..."
    proot-distro install "$DISTRO"

    echo "Configuring inside $DISTRO..."

    proot-distro login "$DISTRO" -- /bin/bash <<EOF
apt update && apt upgrade -y
apt install -y sudo adduser passwd apt-utils dialog tzdata

adduser --gecos "" $USERNAME
echo "$USERNAME ALL=(ALL:ALL) ALL" >> /etc/sudoers

if [[ "$INSTALL_GUI" =~ ^[yY]$ ]]; then
    apt install -y lxde lxterminal tightvncserver
fi
EOF

    if [[ "$INSTALL_GUI" =~ ^[yY]$ ]]; then
    proot-distro login "$DISTRO" -- /bin/bash <<EOF
sudo -u $USERNAME bash <<EOD
vncserver :1
vncserver -kill :1

mkdir -p /home/$USERNAME/.vnc
cat > /home/$USERNAME/.vnc/xstartup <<'EOS'
#!/bin/bash
xrdb \$HOME/.Xresources
exec startlxde &
EOS

chmod +x /home/$USERNAME/.vnc/xstartup

echo "alias startvnc='vncserver -geometry $RES :1'" >> /home/$USERNAME/.bashrc
echo "alias stopvnc='vncserver -kill :1'" >> /home/$USERNAME/.bashrc
EOD
EOF
    fi

    echo "Saving config..."
    cat > "$CONFIG_DIR/$DISTRO.conf" <<EOF
DISTRO=$DISTRO
USERNAME=$USERNAME
GUI=$INSTALL_GUI
RESOLUTION=$RES
EOF

    echo "Creating Termux alias for $DISTRO..."

    ALIAS_CMD="proot-distro login $DISTRO -- su - $USERNAME"

    if [[ "$INSTALL_GUI" =~ ^[yY]$ ]]; then
        ALIAS_CMD="$ALIAS_CMD -c 'startvnc; bash'"
    else
        ALIAS_CMD="$ALIAS_CMD -c 'bash'"
    fi

    echo "alias launch-$DISTRO=\"$ALIAS_CMD\"" >> $HOME/.bashrc

    echo "=== Installation complete! ==="
    echo "Login with: proot-distro login $DISTRO --"
    echo "Switch user: su - $USERNAME"
    [[ "$INSTALL_GUI" =~ ^[yY]$ ]] && echo "Start desktop: startvnc"
    echo "Quick launch: launch-$DISTRO"
}

uninstall_one() {
    echo "Installed distros:"
    ls "$CONFIG_DIR" | sed 's/.conf//'

    read -p "Enter distro to uninstall: " DISTRO

    CONFIG_FILE="$CONFIG_DIR/$DISTRO.conf"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "No config found for $DISTRO"
        exit 1
    fi

    read -p "Remove distro '$DISTRO'? (y/N): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[yY]$ ]] && exit 0

    proot-distro remove "$DISTRO"
    rm -f "$CONFIG_FILE"

    sed -i "/alias launch-$DISTRO=/d" $HOME/.bashrc

    echo "Removed $DISTRO"
}

uninstall_all() {
    echo "This will remove ALL installed distros."
    read -p "Are you sure? (y/N): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[yY]$ ]] && exit 0

    for FILE in "$CONFIG_DIR"/*.conf; do
        [[ -e "$FILE" ]] || continue
        source "$FILE"
        echo "Removing $DISTRO..."
        proot-distro remove "$DISTRO"
        rm -f "$FILE"
    done

    sed -i "/alias launch-/d" $HOME/.bashrc

    echo "All distros removed."

    read -p "Remove proot-distro as well? (y/N): " REMOVE_PROOT
    if [[ "$REMOVE_PROOT" =~ ^[yY]$ ]]; then
        apt remove -y proot-distro
    fi

    echo "Cleanup complete."
}

menu
