#!/bin/bash

# Exit on any error
set -e

# Update packages
echo "Updating packages..."
sudo yum update -y

# Install Docker via Amazon Extras
echo "Installing Docker..."
sudo amazon-linux-extras install docker -y
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group
echo "Adding user to docker group..."
sudo usermod -aG docker $USER

# Install Docker Compose
DOCKER_COMPOSE_VERSION="v2.31.0"
echo "Installing Docker Compose ${DOCKER_COMPOSE_VERSION}..."
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
     -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
echo "Verifying Docker Compose version..."
docker-compose --version

# Create volume for Portainer
echo "Creating Portainer volume..."
docker volume create portainer_data

# Install Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# Install ZeroTier
echo "Installing ZeroTier..."
curl -s https://install.zerotier.com | sudo bash

# Run Portainer container
echo "Starting Portainer..."
docker run -d \
  --name portainer \
  --restart=always \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce

echo
echo "🎉 Installation complete!"
echo "→ Portainer is now running on http://localhost:9000"
echo "→ You may need to log out and log back in for Docker group changes to take effect."
