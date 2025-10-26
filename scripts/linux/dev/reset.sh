#!/bin/bash

# Docker Compose 완전 초기화 스크립트 (Linux/Mac)

echo "⚠️  WARNING: This will DELETE ALL DATA!"
read -p "Are you sure? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "❌ Cancelled"
    exit 1
fi

echo ""
echo "🗑️  Removing all containers and volumes..."

# Docker Compose 완전 삭제
docker-compose down -v

# 볼륨 폴더 삭제
if [ -d "volumes" ]; then
    rm -rf volumes
    echo "✅ Volumes directory deleted"
fi

echo ""
echo "✅ Complete reset finished!"
echo ""
echo "💡 To start fresh:"
echo "   docker-compose up -d"

