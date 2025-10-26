#!/bin/bash

# Docker Compose 중지 스크립트 (Linux/Mac)

echo "🛑 Stopping all services..."

# Docker Compose 중지
docker-compose stop

echo ""
echo "✅ All services stopped!"
echo ""
echo "💡 To remove containers:"
echo "   docker-compose down"
echo ""
echo "💡 To remove containers + volumes (데이터 삭제):"
echo "   docker-compose down -v"

