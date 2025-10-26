#!/bin/bash

# Docker Compose 실행 스크립트 (프로덕션 환경)

echo "🚀 Starting Milvus + PostgreSQL + Attu (PRODUCTION)..."

# 환경 변수 확인
if [ -z "$STORAGE_SERVER_PATH" ]; then
    echo "❌ ERROR: STORAGE_SERVER_PATH 환경 변수가 설정되지 않았습니다."
    echo ""
    echo "💡 사용 방법:"
    echo "   1. .env 파일 생성:"
    echo "      echo 'STORAGE_SERVER_PATH=/mnt/storage/rag-data' > .env"
    echo ""
    echo "   2. 또는 환경 변수 직접 설정:"
    echo "      export STORAGE_SERVER_PATH=/mnt/storage/rag-data"
    echo ""
    exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
    echo "⚠️  WARNING: POSTGRES_PASSWORD 환경 변수가 설정되지 않았습니다."
    echo "   기본값을 사용합니다."
fi

echo ""
echo "📍 Storage Path: $STORAGE_SERVER_PATH"
echo ""

# 스토리지 경로 존재 확인
if [ ! -d "$STORAGE_SERVER_PATH" ]; then
    echo "❌ ERROR: 스토리지 경로가 존재하지 않습니다: $STORAGE_SERVER_PATH"
    echo ""
    echo "💡 먼저 스토리지를 마운트하세요:"
    echo "   ./mount-storage.sh"
    echo ""
    exit 1
fi

# 하위 디렉토리 생성
echo "📁 Creating subdirectories..."
mkdir -p $STORAGE_SERVER_PATH/{milvus,postgres,etcd,minio}

# Docker Compose 실행 (프로덕션 파일 사용)
cd ../../../  # 프로젝트 루트로 이동
docker-compose -f docker-compose.production.yml up -d

# 서비스 시작 대기
echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 15

# 서비스 상태 확인
echo ""
echo "📊 Service Status:"
docker-compose -f docker-compose.production.yml ps

echo ""
echo "✅ Production Services Started!"
echo ""
echo "📍 Access URLs:"
echo "   - Milvus gRPC:        localhost:19530"
echo "   - Attu (Milvus UI):   http://localhost:3000"
echo "   - PostgreSQL:         localhost:5432"
echo "   - MinIO Console:      http://localhost:9001"
echo ""
echo "💡 Next Steps:"
echo "   1. Check status:      ./status-prod.sh"
echo "   2. View logs:         docker-compose -f docker-compose.production.yml logs -f"
echo "   3. Backup data:       ./backup.sh"
echo ""
echo "⚠️  프로덕션 환경이므로 정기적으로 백업하세요!"

