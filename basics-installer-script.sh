#!/bin/bash

# Exit on any error
set -e

# Update package lists
echo "Updating package lists..."
sudo apt-get update -y

# Install Docker
echo "Installing Docker..."
curl -sSL https://get.docker.com/ | sh

# Add current user to docker group
echo "Adding user to docker group..."
sudo usermod -aG docker $USER

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
echo "Verifying Docker Compose version..."
docker-compose --version

# Create volume for Portainer
echo "Creating Portainer volume..."
docker volume create portainer_data

# Installing Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# Install ZeroTier
echo "Installing ZeroTier..."
curl -s https://install.zerotier.com | sudo bash

# Run Portainer container
echo "Starting Portainer..."
docker run -d -p 9000:9000 \
    --name=portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce

echo "Installation complete!"
echo "Portainer should be accessible at http://localhost:9000"
echo "Note: You may need to log out and back in for Docker group changes to take effect"
