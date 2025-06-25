#!/bin/bash

# ==============================================================================
# Zoraxy Reverse Proxy Installer
#
# This script automates the installation of Docker, Docker Compose, and the
# Zoraxy reverse proxy.
#
# It performs the following steps:
# 1. Checks if the script is run with root privileges.
# 2. Checks if Docker is installed. If not, it installs Docker Engine.
# 3. Checks if Docker Compose is installed. If not, it installs the plugin.
# 4. Prompts the user for their timezone.
# 5. Creates the necessary directories for Zoraxy's data and configuration.
# 6. Runs the Zoraxy container with the specified settings.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- SCRIPT CONFIGURATION ---
DEFAULT_TIMEZONE="America/Vancouver"
ZORaxy_CONFIG_DIR="/apps/zoraxy/config"
ZORaxy_DB_DIR="/apps/zoraxy/db"

# --- HELPER FUNCTIONS ---

# Function to print a message with a colored prefix
print_info() {
    echo -e "\n\e[1;34m[INFO]\e[0m $1"
}

print_success() {
    echo -e "\e[1;32m[SUCCESS]\e[0m $1"
}

print_error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1" >&2
}

# --- PRE-FLIGHT CHECKS ---

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
  print_error "This script must be run as root. Please use sudo."
  exit 1
fi

# --- DOCKER INSTALLATION ---

# 2. Check for and install Docker if it's not present
if ! command -v docker &> /dev/null; then
    print_info "Docker not found. Installing Docker Engine..."
    # Update package information
    apt-get update
    # Install prerequisite packages
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    # Add the Docker repository to Apt sources
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    # Update package information with the new repo
    apt-get update
    # Install Docker Engine, CLI, and Containerd
    apt-get install -y docker-ce docker-ce-cli containerd.io
    print_success "Docker Engine installed successfully."
else
    print_info "Docker is already installed. Skipping installation."
fi

# 3. Check for and install Docker Compose if it's not present
if ! docker compose version &> /dev/null; then
    print_info "Docker Compose not found. Installing Docker Compose plugin..."
    apt-get install -y docker-compose-plugin
    print_success "Docker Compose plugin installed successfully."
else
    print_info "Docker Compose is already installed. Skipping installation."
fi

# --- ZORaxy CONFIGURATION ---

# 4. Get timezone from user
print_info "Please specify your timezone."
read -p "Enter your timezone (default: $DEFAULT_TIMEZONE): " USER_TIMEZONE

# Use default if the user input is empty
TIMEZONE=${USER_TIMEZONE:-$DEFAULT_TIMEZONE}
print_info "Using timezone: $TIMEZONE"

# --- ZORaxy DEPLOYMENT ---

print_info "Preparing directories for Zoraxy..."
mkdir -p "$ZORaxy_CONFIG_DIR"
mkdir -p "$ZORaxy_DB_DIR"
print_success "Directories created at /apps/zoraxy/"

print_info "Pulling the latest Zoraxy image..."
docker pull zoraxydocker/zoraxy:latest

print_info "Stopping and removing any existing Zoraxy container..."
docker stop zoraxy &> /dev/null || true
docker rm zoraxy &> /dev/null || true

print_info "Deploying Zoraxy container..."
docker run -d \
  --name=zoraxy \
  --restart unless-stopped \
  -p 80:80 \
  -p 443:443 \
  -p 8000:8000 \
  -v "$ZORaxy_CONFIG_DIR":/opt/zoraxy/data/ \
  -v "$ZORaxy_DB_DIR":/opt/zoraxy/db/ \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc/localtime:/etc/localtime:ro \
  -e TZ="$TIMEZONE" \
  -e FASTGEOIP="true" \
  -e ZEROTIER="True" \
  -e PORT="8000" \
  zoraxydocker/zoraxy:latest

# --- FINALIZATION ---

print_success "Zoraxy has been deployed successfully!"
echo "You can access the Zoraxy web interface by navigating to:"
echo "http://<your-server-ip>:8000"

