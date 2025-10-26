#!/bin/bash

# Docker Compose 상태 확인 스크립트 (Linux/Mac)

echo "📊 Service Status:"
echo "=================="
docker-compose ps

echo ""
echo "💾 Volume Usage:"
echo "================"
docker volume ls | grep milvus

echo ""
echo "🔍 Health Status:"
echo "=================="
docker-compose ps --format "table {{.Name}}\t{{.Status}}" | grep -E "healthy|unhealthy|starting"

echo ""
echo "📈 Resource Usage:"
echo "=================="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" \
  milvus-standalone milvus-etcd milvus-minio rag-postgres milvus-attu 2>/dev/null || \
  echo "⚠️ Some containers are not running"

