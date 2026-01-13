# Linux on Android

![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![Linux](https://img.shields.io/badge/Userspace-GNU%2FLinux-FCC624?logo=linux&logoColor=black)
![No Root](https://img.shields.io/badge/Privilege-No%20Root%20Required-success)

---

## Overview

**Linux on Android** is a fully automated script that installs, configures, and manages full Linux distributions inside **Termux** using **proot-distro**, all without requiring root access.

This tool is designed to make Linux‑on‑Android setups **reproducible**, **beginner‑friendly**, and **frictionless**, while giving old Android devices a second life as:

- Lightweight Linux servers  
- Development sandboxes  
- Learning environments  
- Automation nodes  
- Personal experimentation machines  

The script handles everything automatically:

- Distro installation  
- User creation  
- Sudo configuration  
- Optional LXDE desktop setup  
- VNC configuration  
- Automatic cleanup of stale VNC lock files  
- Clean uninstall (single distro or all)  

No aliases. No manual steps. No guesswork.

👉 **[Manual Installation Guide](docs/MANUAL-INSTALL.md)** For users who prefer to install everything manually.

---

## Features

### ✔ Fully automated installation  
No interactive prompts inside the distro. Everything is handled cleanly.

### ✔ Optional LXDE desktop + VNC  
Choose whether to install a GUI.  
VNC is configured automatically with a working `xstartup`.

### ✔ Automatic VNC lock cleanup  
Fixes the common `Cannot start VNC:1` issue by removing stale lock files.

### ✔ Safe sudo setup  
Creates a non‑root user with passwordless sudo via `/etc/sudoers.d`.

### ✔ Clean uninstall  
Remove one distro or wipe all distros + configs.

### ✔ No aliases  
You control how you start/stop VNC and how you log in.

---

## Requirements

- Android 8.0+  
- Termux (from F‑Droid recommended)  
- 4–6 GB free storage  
- Internet connection  
- Optional: VNC viewer app (RealVNC, bVNC, etc.)

---

## Installation

1. Install **Termux** from F-Droid:  
   https://f-droid.org/packages/com.termux/

2. Update Termux packages and install Git:

   ```bash
   apt update && apt upgrade -y
   apt install git -y
   ```

3. Clone this repository:

```bash
git clone https://github.com/uzairmukadam/linux-on-android.git
cd linux-on-android
```

4. Make the script executable:

```bash
chmod +x linux-on-android.sh
```

5. Run the script:

```bash
./linux-on-android.sh
```

6. Follow the on‑screen prompts.

---

## What the Script Does

### 1. Installs your chosen Linux distro  
Supports any distro available through `proot-distro`.

### 2. Creates a non‑root user  
Passwordless login, safe sudo access.

### 3. Optional LXDE desktop setup  
If selected, the script installs:

- LXDE  
- TightVNCServer  
- A working `xstartup`  
- A VNC password  
- Automatic lock‑file cleanup  
- A test VNC session to initialize configs  

### 4. Saves configuration  
Each installed distro gets a config file in:

```
$PREFIX/etc/linux-on-android/<distro>.conf
```

### 5. Provides clean uninstall options  
Remove one distro or all of them.

---

## Using Your Linux Environment

### Login to your distro:

```bash
proot-distro login <distro> --
```

### Switch to your user:

```bash
su - <username>
```

---

## Using VNC (if GUI installed)

### Start VNC:

```bash
vncserver -geometry 1920x1080 :1
```

### Stop VNC:

```bash
vncserver -kill :1
```

### Connect from Android VNC viewer:

```
localhost:5901
```

Password: `1234` (default)

---

## How to Cleanly Shut Down Everything

### 1. Stop the VNC desktop  
```bash
vncserver -kill :1
```

### 2. Exit the user session  
```bash
exit
```

### 3. Exit the distro  
```bash
exit
```

### 4. Kill any leftover proot processes (optional)  
From Termux:

```bash
pkill -9 -f proot
```

### 5. Close Termux  
```bash
exit
```

Then swipe Termux away from recent apps.

This fully shuts down the Linux environment.

---

## Uninstalling

### Remove a single distro:

```bash
./linux-on-android.sh
```

Choose: **Uninstall a specific distro**

### Remove all distros:

Choose: **Uninstall ALL distros**

You can also optionally remove `proot-distro`.

---

## Supported Distributions

Any distro supported by `proot-distro`, including:

- Debian  
- Ubuntu  
- Arch Linux  
- Fedora  
- Alpine  
- Void Linux  

---

## Known Limitations

- No GPU acceleration (Android does not expose GPU to proot)  
- No systemd  
- VNC performance depends on device hardware  
- Some desktop apps may require additional packages  

---

## Closing Thoughts

This project is built for people who love repurposing old hardware, reducing e‑waste, and exploring what’s possible with minimal resources.  
If you have ideas, improvements, or want to contribute — feel free to open an issue or reach out.
