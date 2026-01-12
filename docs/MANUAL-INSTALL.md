# Linux on Android — Manual Installation Guide

![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![Linux](https://img.shields.io/badge/Userspace-GNU%2FLinux-FCC624?logo=linux&logoColor=black)
![No Root](https://img.shields.io/badge/Privilege-No%20Root%20Required-success)

---

## 📌 Overview

This guide walks you through the **manual installation** of Linux distributions on Android using **Termux** and **proot-distro**, without relying on the automation script.  
It is intended for users who want full control, prefer transparency, or want to understand how everything works under the hood.

The steps here closely follow the original workflow used to build the automation script.

If you prefer a fully automated setup, see the main README and use the installer script instead.

---

## 📦 Requirements

- Android **8.0+**
- **Termux** (from F-Droid)
- Internet connection
- 4–6 GB free storage
- Optional: VNC viewer (RealVNC, bVNC, etc.)

---

# 🧰 1. Install Termux & Update Packages

Install Termux from F-Droid, then run:

```bash
apt update && apt upgrade -y
apt install git -y
```

Clone the repository if you want to reference the automation script (Cloning is optional for manual installation):

```bash
git clone https://github.com/uzairmukadam/linux-on-android.git
```

# 📥 2. Install `proot-distro`

```bash
apt install proot-distro -y
```

List available distros:

```bash
proot-distro list
```

---

# 🐧 3. Install a Linux Distribution

Example: install Debian

```bash
proot-distro install debian
```

You may replace `debian` with:

- `ubuntu`
- `archlinux`
- `alpine`
- `fedora`
- or any other supported distro

---

# 🔑 4. Enter the Linux Environment

Use the updated login syntax:

```bash
proot-distro login debian --
```

You are now inside the Linux environment.

---

# 👤 5. Install Essential Packages & Create a User

Some rootfs images are minimal, so install essentials first:

```bash
apt update && apt upgrade -y
apt install -y sudo adduser passwd apt-utils dialog tzdata
```

Create a non-root user:

```bash
adduser username
```

Give sudo access:

```bash
echo "username ALL=(ALL:ALL) ALL" >> /etc/sudoers
```

Switch to the new user:

```bash
su - username
```

---

# 🖥️ 6. (Optional) Install LXDE Desktop + VNC

Still inside the distro:

### Install LXDE and VNC server:

```bash
apt install -y lxde lxterminal tightvncserver
```

### Initialize VNC:

```bash
vncserver :1
vncserver -kill :1
```

### Create the `xstartup` file:

```bash
mkdir -p ~/.vnc
nano ~/.vnc/xstartup
```

Paste:

```
#!/bin/bash
xrdb $HOME/.Xresources
exec startlxde &
```

Make it executable:

```bash
chmod +x ~/.vnc/xstartup
```

---

# 🖧 7. Start the Desktop Environment

Start VNC:

```bash
vncserver -geometry 1920x1080 :1
```

Connect using any VNC viewer to:

```
localhost:5901
```

Stop VNC:

```bash
vncserver -kill :1
```

---

# 🧹 8. Uninstall a Linux Distribution

List installed distros:

```bash
proot-distro list
```

Remove one:

```bash
proot-distro remove debian
```

---

# 🗑️ 9. (Optional) Remove `proot-distro`

```bash
apt remove proot-distro -y
```

---

# 🧠 Tips for Manual Users

- Debian is the most stable for proot environments  
- Alpine is extremely lightweight but requires more manual setup  
- Use lower VNC resolutions for better performance  
- Avoid heavy desktops like GNOME/KDE  
- You can install `code-server` for a VS Code-like experience  

---

# 🗒️ Summary of Manual Steps

1. Install Termux  
2. Install `proot-distro`  
3. Install a Linux distro  
4. Enter the distro  
5. Install essential packages  
6. Create a user  
7. (Optional) Install LXDE + VNC  
8. Start VNC and connect  
9. Uninstall when done  

This guide gives you full control over every part of the setup.

---

## 📬 Contributions

If you discover improvements or want to expand this guide, feel free to open an issue or submit a pull request.

