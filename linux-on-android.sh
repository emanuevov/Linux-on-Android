#!/bin/bash
set -e

echo "👋 Welcome to Linux on Android Manager"

# ----------------------------
# Step 0: Update Termux
# ----------------------------
echo "🔄 Updating Termux packages..."
apt update && apt upgrade -y

# ----------------------------
# Step 1: Install proot-distro if missing
# ----------------------------
if ! command -v proot-distro &> /dev/null; then
    echo "📦 Installing proot-distro..."
    apt install proot-distro -y
fi

# ----------------------------
# Step 2: Choose Action
# ----------------------------
echo "What do you want to do?"
echo "1) Install a Linux distro"
echo "2) Uninstall a Linux distro"
read -p "Enter 1 or 2: " ACTION

# ----------------------------
# INSTALLATION FLOW
# ----------------------------
if [[ "$ACTION" == "1" ]]; then
    # List available distros
    echo "📋 Available Linux distributions:"
    proot-distro list

    read -p "Enter the distro you want to install (e.g., debian, ubuntu): " DISTRO
    read -p "Enter the username you want to create inside Linux: " LINUX_USER
    read -p "Do you want to install a desktop environment (LXDE + VNC)? (y/N): " INSTALL_GUI

    # Ask for VNC resolution if GUI is requested
    if [[ "$INSTALL_GUI" == "y" || "$INSTALL_GUI" == "Y" ]]; then
        echo "Available resolutions: 1024x768, 1280x720, 1920x1080"
        read -p "Enter desired VNC resolution (default 1920x1080): " VNC_RES
        VNC_RES=${VNC_RES:-1920x1080}
    fi

    # Confirm
    echo "--------------------------------"
    echo "Summary of selections:"
    echo "Linux Distro: $DISTRO"
    echo "Username: $LINUX_USER"
    echo "Install Desktop: $INSTALL_GUI"
    [[ -n "$VNC_RES" ]] && echo "VNC Resolution: $VNC_RES"
    echo "--------------------------------"
    read -p "Proceed with installation? (y/N): " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "Aborting installation."
        exit 0
    fi

    # Install the distro
    echo "🚀 Installing $DISTRO..."
    proot-distro install "$DISTRO"

    echo "🎉 Installation complete!"
    echo "Logging in to $DISTRO to configure user..."
    proot-distro login "$DISTRO" /bin/bash <<EOF
# Inside distro
echo "📦 Updating packages..."
apt update && apt upgrade -y

# Create user
echo "👤 Creating user '$LINUX_USER'..."
apt install sudo -y
adduser --gecos "" "$LINUX_USER"
usermod -aG sudo "$LINUX_USER"
echo "✅ User '$LINUX_USER' created"

# Switch to new user automatically
echo "🔄 Switching to $LINUX_USER..."
su - "$LINUX_USER"

# Optional aliases
echo "📌 Creating helpful aliases..."
echo "alias startvnc='vncserver -geometry $VNC_RES :1'" >> ~/.bashrc
echo "alias stopvnc='vncserver -kill :1'" >> ~/.bashrc
echo "alias login='proot-distro login $DISTRO'" >> ~/.bashrc
EOF

    # Optional GUI setup
    if [[ "$INSTALL_GUI" == "y" || "$INSTALL_GUI" == "Y" ]]; then
        proot-distro login "$DISTRO" /bin/bash <<EOF
echo "📦 Installing LXDE..."
apt install lxde -y
echo "📦 Installing TightVNC server..."
apt install tightvncserver -y

# Initial VNC setup
vncserver :1
vncserver -kill :1
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'EOD'
#!/bin/bash
xrdb \$HOME/.Xresources
exec startlxde &
EOD
chmod +x ~/.vnc/xstartup

echo "✅ Desktop setup complete!"
echo "Start desktop with: startvnc"
EOF
    fi

    echo "🎉 Installation finished!"
    echo "Login with: proot-distro login $DISTRO"
    if [[ "$INSTALL_GUI" == "y" || "$INSTALL_GUI" == "Y" ]]; then
        echo "Start desktop with: startvnc"
        echo "Stop desktop with: stopvnc"
    fi

# ----------------------------
# UNINSTALL FLOW
# ----------------------------
elif [[ "$ACTION" == "2" ]]; then
    echo "📋 Installed Linux distributions:"
    proot-distro list

    read -p "Enter the distro you want to uninstall: " DISTRO_REMOVE
    read -p "⚠️ Are you sure you want to completely remove '$DISTRO_REMOVE'? (y/N): " CONFIRM_REMOVE
    if [[ "$CONFIRM_REMOVE" != "y" && "$CONFIRM_REMOVE" != "Y" ]]; then
        echo "Aborting uninstall."
        exit 0
    fi

    echo "🗑 Removing $DISTRO_REMOVE..."
    proot-distro remove "$DISTRO_REMOVE"
    echo "✅ $DISTRO_REMOVE removed!"

    read -p "Do you want to remove proot-distro as well? (y/N): " REMOVE_PROOT
    if [[ "$REMOVE_PROOT" == "y" || "$REMOVE_PROOT" == "Y" ]]; then
        apt remove proot-distro -y
        echo "✅ proot-distro removed!"
    fi
else
    echo "❌ Invalid option. Exiting."
    exit 1
fi
