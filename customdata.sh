#!/bin/bash

apt-get update -y
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
sleep 30
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
systemctl restart docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
git clone https://github.com/PracowniaProblemowa2023/docker-guard-image-backend.git /home/adminuser/docker-guard-image-backend
DOCKER_BUILDKIT=1 docker build /home/adminuser/docker-guard-image-backend -t docker-guard-image-backend:1.0.0
git clone https://github.com/PracowniaProblemowa2023/docker-guard-image-frontend.git /home/adminuser/docker-guard-image-frontend
DOCKER_BUILDKIT=1 docker build /home/adminuser/docker-guard-image-frontend -t docker-guard-image-frontend:1.0.0
chmod 777 /home/adminuser/key.pem
chmod 777 /home/adminuser/cert.pem