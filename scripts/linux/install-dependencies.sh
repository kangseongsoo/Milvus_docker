#!/bin/bash

# 필요한 도구 설치 스크립트 (Linux)

echo "🔧 Installing dependencies..."

# OS 확인
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Cannot determine OS"
    exit 1
fi

# Docker 설치 확인
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        # Ubuntu/Debian
        sudo apt-get update
        sudo apt-get install -y docker.io docker-compose
        sudo systemctl start docker
        sudo systemctl enable docker
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        # CentOS/RHEL
        sudo yum install -y docker docker-compose
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo "⚠️ Unsupported OS: $OS"
        echo "Please install Docker manually"
        exit 1
    fi
    
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Docker Compose 설치 확인
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

# 현재 사용자를 docker 그룹에 추가
echo ""
echo "👤 Adding current user to docker group..."
sudo usermod -aG docker $USER

echo ""
echo "✅ All dependencies installed!"
echo ""
echo "⚠️ IMPORTANT: Please log out and log back in for group changes to take effect"
echo ""
echo "💡 Next steps:"
echo "   1. Log out and log back in"
echo "   2. Run: ./start.sh"

