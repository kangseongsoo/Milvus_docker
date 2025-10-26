#!/bin/bash

# 프로덕션 데이터 백업 스크립트

BACKUP_BASE_DIR="/var/backups/milvus-rag"
BACKUP_DIR="$BACKUP_BASE_DIR/$(date +%Y%m%d_%H%M%S)"

echo "💾 Starting Production Backup..."
echo "================================"
echo ""

# 환경 변수 확인
if [ -z "$STORAGE_SERVER_PATH" ]; then
    echo "❌ ERROR: STORAGE_SERVER_PATH 환경 변수가 설정되지 않았습니다."
    exit 1
fi

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR
echo "📁 Backup directory: $BACKUP_DIR"

# 프로젝트 루트로 이동
cd ../../../

# PostgreSQL 백업
echo ""
echo "📦 Backing up PostgreSQL..."
docker-compose -f docker-compose.production.yml exec -T postgres pg_dump -U postgres ${POSTGRES_DB:-rag_db_chatty} > $BACKUP_DIR/postgres_dump.sql
if [ $? -eq 0 ]; then
    echo "   ✅ PostgreSQL backup completed"
    gzip $BACKUP_DIR/postgres_dump.sql
    echo "   ✅ Compressed: postgres_dump.sql.gz"
else
    echo "   ❌ PostgreSQL backup failed"
fi

# Milvus 데이터 백업 (rsync 사용)
echo ""
echo "📦 Backing up Milvus data..."
if [ -d "$STORAGE_SERVER_PATH/milvus" ]; then
    rsync -az --info=progress2 $STORAGE_SERVER_PATH/milvus/ $BACKUP_DIR/milvus_data/
    if [ $? -eq 0 ]; then
        echo "   ✅ Milvus backup completed"
    else
        echo "   ❌ Milvus backup failed"
    fi
else
    echo "   ⚠️ Milvus data not found"
fi

# PostgreSQL 볼륨 백업
echo ""
echo "📦 Backing up PostgreSQL data files..."
if [ -d "$STORAGE_SERVER_PATH/postgres" ]; then
    rsync -az --info=progress2 $STORAGE_SERVER_PATH/postgres/ $BACKUP_DIR/postgres_data/
    if [ $? -eq 0 ]; then
        echo "   ✅ PostgreSQL data backup completed"
    else
        echo "   ❌ PostgreSQL data backup failed"
    fi
else
    echo "   ⚠️ PostgreSQL data not found"
fi

# MinIO 백업 (옵션)
echo ""
echo "📦 Backing up MinIO data..."
if [ -d "$STORAGE_SERVER_PATH/minio" ]; then
    rsync -az --info=progress2 $STORAGE_SERVER_PATH/minio/ $BACKUP_DIR/minio_data/
    if [ $? -eq 0 ]; then
        echo "   ✅ MinIO backup completed"
    else
        echo "   ❌ MinIO backup failed"
    fi
else
    echo "   ⚠️ MinIO data not found"
fi

# etcd 백업
echo ""
echo "📦 Backing up etcd data..."
if [ -d "$STORAGE_SERVER_PATH/etcd" ]; then
    rsync -az --info=progress2 $STORAGE_SERVER_PATH/etcd/ $BACKUP_DIR/etcd_data/
    if [ $? -eq 0 ]; then
        echo "   ✅ etcd backup completed"
    else
        echo "   ❌ etcd backup failed"
    fi
else
    echo "   ⚠️ etcd data not found"
fi

# 메타데이터 파일 생성
echo ""
echo "📝 Creating backup metadata..."
cat > $BACKUP_DIR/backup_info.txt <<EOF
Backup Date: $(date)
Hostname: $(hostname)
Storage Path: $STORAGE_SERVER_PATH
Docker Compose Version: $(docker-compose --version)
Container Status:
$(docker-compose -f docker-compose.production.yml ps)
EOF

echo "   ✅ Metadata created"

# 백업 크기 확인
echo ""
echo "✅ Backup completed!"
echo ""
echo "📊 Backup Details:"
echo "   Location: $BACKUP_DIR"
echo "   Size:     $(du -sh $BACKUP_DIR | cut -f1)"
echo ""
echo "📂 Backup Contents:"
du -sh $BACKUP_DIR/* 2>/dev/null

# 오래된 백업 정리 (30일 이상 된 백업 삭제)
echo ""
echo "🧹 Cleaning old backups (older than 30 days)..."
find $BACKUP_BASE_DIR -type d -mtime +30 -exec rm -rf {} + 2>/dev/null
echo "   ✅ Cleanup completed"

echo ""
echo "💡 복원 방법:"
echo "   1. 서비스 중지:    ./stop-prod.sh"
echo "   2. 데이터 복원:    rsync -az $BACKUP_DIR/* $STORAGE_SERVER_PATH/"
echo "   3. 서비스 시작:    ./start-prod.sh"

