#!/bin/bash
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
sudo apt update -y
sudo apt install --install-recommends -y winehq-stable
dpkg --add-architecture i386 && apt-get update && apt-get install -y wine32:i386
echo "Done installing Wine. Consider running 'sudo apt install -f' if needed, to fix any broken packages."
