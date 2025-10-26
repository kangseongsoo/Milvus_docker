#!/bin/bash

# 외부 스토리지 마운트 스크립트 (Linux)

echo "📦 Storage Server Mount Script"
echo "=============================="
echo ""

# 설정 변수
STORAGE_TYPE=""  # nfs, smb, local
STORAGE_SERVER=""
STORAGE_PATH=""
MOUNT_POINT="/mnt/storage/rag-data"

# 사용자 입력
echo "스토리지 타입을 선택하세요:"
echo "1) NFS (Network File System)"
echo "2) SMB/CIFS (Windows 공유)"
echo "3) 로컬 디스크"
read -p "선택 (1-3): " choice

case $choice in
    1)
        STORAGE_TYPE="nfs"
        read -p "NFS 서버 주소 (예: 192.168.1.100): " STORAGE_SERVER
        read -p "NFS 공유 경로 (예: /export/rag-data): " STORAGE_PATH
        ;;
    2)
        STORAGE_TYPE="smb"
        read -p "SMB 서버 주소 (예: 192.168.1.100): " STORAGE_SERVER
        read -p "SMB 공유 경로 (예: /RAGData): " STORAGE_PATH
        read -p "SMB 사용자명: " SMB_USER
        read -sp "SMB 비밀번호: " SMB_PASS
        echo ""
        ;;
    3)
        STORAGE_TYPE="local"
        read -p "로컬 디스크 경로 (예: /data/rag-storage): " STORAGE_PATH
        ;;
    *)
        echo "❌ 잘못된 선택"
        exit 1
        ;;
esac

read -p "마운트 포인트 [${MOUNT_POINT}]: " input_mount
if [ ! -z "$input_mount" ]; then
    MOUNT_POINT=$input_mount
fi

# 마운트 포인트 생성
echo ""
echo "📁 Creating mount point: $MOUNT_POINT"
sudo mkdir -p $MOUNT_POINT

# 스토리지 마운트
echo ""
echo "🔧 Mounting storage..."

case $STORAGE_TYPE in
    nfs)
        # NFS 클라이언트 설치
        sudo apt-get install -y nfs-common
        
        # NFS 마운트
        sudo mount -t nfs ${STORAGE_SERVER}:${STORAGE_PATH} $MOUNT_POINT
        
        # /etc/fstab에 추가 (재부팅 후에도 유지)
        echo "${STORAGE_SERVER}:${STORAGE_PATH} $MOUNT_POINT nfs defaults 0 0" | sudo tee -a /etc/fstab
        ;;
        
    smb)
        # CIFS 클라이언트 설치
        sudo apt-get install -y cifs-utils
        
        # 인증 파일 생성
        CREDS_FILE="/root/.smb_credentials"
        echo "username=${SMB_USER}" | sudo tee $CREDS_FILE > /dev/null
        echo "password=${SMB_PASS}" | sudo tee -a $CREDS_FILE > /dev/null
        sudo chmod 600 $CREDS_FILE
        
        # SMB 마운트
        sudo mount -t cifs //${STORAGE_SERVER}${STORAGE_PATH} $MOUNT_POINT -o credentials=$CREDS_FILE
        
        # /etc/fstab에 추가
        echo "//${STORAGE_SERVER}${STORAGE_PATH} $MOUNT_POINT cifs credentials=$CREDS_FILE 0 0" | sudo tee -a /etc/fstab
        ;;
        
    local)
        # 로컬 디스크는 심볼릭 링크만
        if [ ! -d "$STORAGE_PATH" ]; then
            sudo mkdir -p $STORAGE_PATH
        fi
        
        if [ "$STORAGE_PATH" != "$MOUNT_POINT" ]; then
            sudo ln -s $STORAGE_PATH $MOUNT_POINT
        fi
        ;;
esac

# 마운트 확인
echo ""
echo "✅ Mount completed!"
echo ""
df -h $MOUNT_POINT

# 디렉토리 생성
echo ""
echo "📁 Creating subdirectories..."
sudo mkdir -p $MOUNT_POINT/{milvus,postgres,etcd,minio}
sudo chown -R $USER:$USER $MOUNT_POINT

echo ""
echo "✅ Storage setup completed!"
echo ""
echo "📍 Mount point: $MOUNT_POINT"
echo ""
echo "💡 Next steps:"
echo "   1. Edit .env file:"
echo "      STORAGE_SERVER_PATH=$MOUNT_POINT"
echo ""
echo "   2. Start Docker Compose:"
echo "      docker-compose -f docker-compose.production.yml up -d"

