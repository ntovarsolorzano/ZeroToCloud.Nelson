#!/bin/bash

echo "===== This script install NoMachine and all the basic components to remotely connect to a Debian-based server via Graphical Interface."

set -e

# This script must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run as root or use sudo."
   exit 1
fi

sudo DEBIAN_FRONTEND=noninteractive apt install -y keyboard-configuration

echo "===== Updating APT and installing required tools..."
apt update -y
apt install -y wget curl

echo "===== Installing Snap..."
apt install -y snapd

echo "===== Installing Flakpak..."
apt install flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "===== Installing XFCE desktop environment..."
apt install -y xfce4 xfce4-goodies

echo "===== Installing core X11 server components (Xorg)..."
apt install -y xserver-xorg dbus-x11

echo "===== Optionally, installing network-manager for GUI connection management..."
apt install -y network-manager

echo "===== Installing a light web browser: Midori and Firefox (default)..."
snap install midori
sudo apt install -y firefox-esr
xdg-settings set default-web-browser firefox-esr.desktop

# Uncomment if you want a display manager for console GUI login:
echo "Installing LightDM display manager (optional)..."
apt install -y lightdm

echo "===== Downloading NoMachine .deb package..."
cd /tmp
wget https://download.nomachine.com/download/8.16/Linux/nomachine_8.16.1_1_amd64.deb

echo "===== Installing NoMachine..."
dpkg -i nomachine_8.16.1_1_amd64.deb || apt-get install -f -y

echo "===== Cleaning up..."
rm -f nomachine_8.16.1_1_amd64.deb
apt autoremove -y

echo "===== Installation complete!"
echo "You can now connect via NoMachine client to your server's IP."
echo "Do not forget to open port 4000 TCP and UDP."

echo "Your IP is: $(curl -4 -sS ifconfig.io)"
