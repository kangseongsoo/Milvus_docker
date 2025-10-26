#!/bin/bash

# 프로덕션 환경 상태 확인 스크립트

echo "📊 Production Service Status"
echo "=============================="
echo ""

# 프로젝트 루트로 이동
cd ../../../

echo "🐳 Container Status:"
echo "-------------------"
docker-compose -f docker-compose.production.yml ps

echo ""
echo "💚 Health Status:"
echo "-----------------"
docker ps --filter "name=milvus" --filter "name=postgres" --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "📈 Resource Usage:"
echo "------------------"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" \
  milvus-standalone milvus-etcd milvus-minio rag-postgres milvus-attu 2>/dev/null || \
  echo "⚠️ Some containers are not running"

echo ""
echo "💾 Storage Usage:"
echo "-----------------"
if [ ! -z "$STORAGE_SERVER_PATH" ] && [ -d "$STORAGE_SERVER_PATH" ]; then
    echo "Storage Path: $STORAGE_SERVER_PATH"
    df -h $STORAGE_SERVER_PATH
    echo ""
    echo "Subdirectory sizes:"
    du -sh $STORAGE_SERVER_PATH/* 2>/dev/null || echo "No data yet"
else
    echo "⚠️ STORAGE_SERVER_PATH not set or not found"
fi

echo ""
echo "🌐 Network Status:"
echo "------------------"
docker network inspect milvus_milvus --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{println}}{{end}}' 2>/dev/null || \
  echo "⚠️ Network not found"

echo ""
echo "📅 Uptime:"
echo "----------"
docker ps --filter "name=milvus-standalone" --format "{{.Status}}"

