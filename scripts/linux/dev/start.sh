#!/bin/bash

# Docker Compose 실행 스크립트 (Linux/Mac)

echo "🐳 Starting Milvus + PostgreSQL + Attu..."

# Docker Compose 실행
docker-compose up -d

# 서비스 시작 대기
echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# 서비스 상태 확인
echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "✅ Services Started!"
echo ""
echo "📍 Access URLs:"
echo "   - Milvus gRPC:        localhost:19530"
echo "   - Attu (Milvus UI):   http://localhost:3000"
echo "   - PostgreSQL:         localhost:5432"
echo "   - MinIO Console:      http://localhost:9001"
echo ""
echo "💡 Next Steps:"
echo "   1. Open Attu:         http://localhost:3000"
echo "   2. Connect to Milvus: localhost:19530"
echo "   3. Start FastAPI:     cd .. && uvicorn app.main:app --reload"

