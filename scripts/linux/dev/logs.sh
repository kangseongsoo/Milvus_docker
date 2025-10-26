#!/bin/bash

# Docker Compose 로그 확인 스크립트 (Linux/Mac)

SERVICE=$1

if [ -z "$SERVICE" ]; then
    echo "📋 Showing logs for all services..."
    docker-compose logs -f
else
    echo "📋 Showing logs for $SERVICE..."
    docker-compose logs -f $SERVICE
fi

# 사용 예시:
# ./logs.sh              # 전체 로그
# ./logs.sh milvus       # Milvus 로그만
# ./logs.sh postgres     # PostgreSQL 로그만

