#!/bin/bash

# Exit on any error
set -e

# Detect package manager
if command -v dnf &>/dev/null; then
  PKG="dnf"
elif command -v yum &>/dev/null; then
  PKG="yum"
else
  echo "ERROR: Neither dnf nor yum found. Exiting." >&2
  exit 1
fi

echo "Using $PKG for package management"

# Update system
echo "Updating packages..."
sudo $PKG update -y

# Install prerequisites for Docker installer (curl comes in handy)
echo "Ensuring curl is installed..."
sudo $PKG install -y curl --allowerasing

# Install Docker via the official get.docker.com script
echo "Installing Docker..."
curl -fsSL https://get.docker.com | sudo sh

# Enable & start Docker service
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group
echo "Adding $USER to docker group..."
sudo usermod -aG docker $USER

# Install Docker Compose
DOCKER_COMPOSE_VERSION="v2.31.0"
echo "Installing Docker Compose ${DOCKER_COMPOSE_VERSION}..."
sudo curl -fsSL \
  "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose
echo "Verifying Docker Compose installation..."
docker-compose --version

# Create Portainer data volume
echo "Creating Portainer data volume..."
docker volume create portainer_data

# Install Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sudo sh

# Install ZeroTier
echo "Installing ZeroTier..."
curl -fsSL https://install.zerotier.com | sudo bash

# Launch Portainer
echo "Starting Portainer..."
docker run -d \
  --name portainer \
  --restart=always \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce

cat <<‑EOF

🎉 All set!

• Portainer → http://localhost:9000  
• Log out/in for your Docker‑group membership to take effect  

EOF
