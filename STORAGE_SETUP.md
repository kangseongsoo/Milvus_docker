# 💾 외부 스토리지 서버 연동 가이드

## 📋 개요

프로덕션 환경에서는 Docker 볼륨 대신 **외부 스토리지 서버**를 사용하여:
- ✅ 데이터 영구 보존
- ✅ 대용량 저장 공간 확보
- ✅ 백업 및 복구 용이
- ✅ 여러 서버에서 공유 가능

## 🎯 지원되는 스토리지 타입

### 1. NFS (Network File System) - 추천 ⭐

**장점:**
- ✅ Linux 네이티브 지원
- ✅ 설정 간단
- ✅ 성능 우수
- ✅ 권한 관리 용이

**사용 사례:**
- Linux/Unix 환경
- 대용량 파일 스토리지

### 2. SMB/CIFS (Windows 공유)

**장점:**
- ✅ Windows 서버와 호환
- ✅ Active Directory 통합

**사용 사례:**
- Windows 파일 서버
- 혼합 환경 (Windows + Linux)

### 3. 클라우드 스토리지

**장점:**
- ✅ 무제한 확장
- ✅ 자동 백업
- ✅ 고가용성

**지원:**
- AWS EFS (NFS)
- Azure Files (SMB/NFS)
- Google Cloud Filestore (NFS)

---

## 🔧 NFS 스토리지 설정 (권장)

### Step 1: NFS 서버 설정 (스토리지 서버)

```bash
# NFS 서버 설치 (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y nfs-kernel-server

# 공유 디렉토리 생성
sudo mkdir -p /export/rag-data
sudo chown nobody:nogroup /export/rag-data
sudo chmod 777 /export/rag-data

# NFS 공유 설정
sudo nano /etc/exports

# 다음 내용 추가:
/export/rag-data    192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
# 설명:
# - 192.168.1.0/24: 허용할 클라이언트 IP 대역
# - rw: 읽기/쓰기 권한
# - sync: 동기 쓰기
# - no_root_squash: root 권한 유지

# NFS 서비스 재시작
sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# 방화벽 설정 (필요시)
sudo ufw allow from 192.168.1.0/24 to any port nfs
```

### Step 2: NFS 클라이언트 설정 (Docker 호스트)

```bash
# NFS 클라이언트 설치
sudo apt-get install -y nfs-common

# 마운트 포인트 생성
sudo mkdir -p /mnt/storage/rag-data

# NFS 마운트
sudo mount -t nfs 192.168.1.100:/export/rag-data /mnt/storage/rag-data

# 마운트 확인
df -h /mnt/storage/rag-data

# 자동 마운트 설정 (재부팅 후에도 유지)
echo "192.168.1.100:/export/rag-data /mnt/storage/rag-data nfs defaults 0 0" | sudo tee -a /etc/fstab

# 서브 디렉토리 생성
sudo mkdir -p /mnt/storage/rag-data/{milvus,postgres,etcd,minio}
sudo chown -R $USER:$USER /mnt/storage/rag-data
```

### Step 3: .env 파일 설정

```bash
# 01.Docker_compose/.env.production 편집
nano .env.production
```

```env
# 외부 스토리지 경로
STORAGE_SERVER_PATH=/mnt/storage/rag-data

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=rag_db_chatty
```

### Step 4: Docker Compose 실행

```bash
# 프로덕션 설정으로 실행
docker-compose -f docker-compose.production.yml --env-file .env.production up -d

# 상태 확인
docker-compose -f docker-compose.production.yml ps
```

---

## 🔧 SMB/CIFS 스토리지 설정

### Step 1: SMB 서버 설정 (Windows Server)

```powershell
# Windows Server에서 공유 폴더 생성
New-Item -Path "D:\RAGData" -ItemType Directory
New-SmbShare -Name "RAGData" -Path "D:\RAGData" -FullAccess "Everyone"

# 또는 GUI:
# 1. 폴더 우클릭 > 속성
# 2. 공유 탭 > 고급 공유
# 3. "이 폴더 공유" 체크
# 4. 권한 설정
```

### Step 2: SMB 클라이언트 설정 (Linux Docker 호스트)

```bash
# CIFS 클라이언트 설치
sudo apt-get install -y cifs-utils

# 인증 파일 생성
sudo nano /root/.smb_credentials
```

```ini
username=administrator
password=your_password
domain=WORKGROUP
```

```bash
# 권한 설정
sudo chmod 600 /root/.smb_credentials

# 마운트 포인트 생성
sudo mkdir -p /mnt/storage/rag-data

# SMB 마운트
sudo mount -t cifs //192.168.1.100/RAGData /mnt/storage/rag-data \
  -o credentials=/root/.smb_credentials,uid=$UID,gid=$GID

# 자동 마운트 설정
echo "//192.168.1.100/RAGData /mnt/storage/rag-data cifs credentials=/root/.smb_credentials,uid=$UID,gid=$GID 0 0" | \
  sudo tee -a /etc/fstab

# 서브 디렉토리 생성
mkdir -p /mnt/storage/rag-data/{milvus,postgres,etcd,minio}
```

---

## ☁️ 클라우드 스토리지 설정

### AWS EFS (Elastic File System)

```bash
# 1. AWS CLI 설치
sudo apt-get install -y amazon-efs-utils

# 2. EFS 마운트
sudo mkdir -p /mnt/efs/rag-data
sudo mount -t efs fs-12345678:/ /mnt/efs/rag-data

# 3. 자동 마운트
echo "fs-12345678:/ /mnt/efs/rag-data efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

# 4. .env 설정
STORAGE_SERVER_PATH=/mnt/efs/rag-data
```

### Azure Files

```bash
# 1. Azure Files 마운트 (SMB)
sudo mkdir -p /mnt/azure/rag-data

# 2. 마운트
sudo mount -t cifs //storageaccount.file.core.windows.net/ragdata /mnt/azure/rag-data \
  -o vers=3.0,username=storageaccount,password=storagekey,dir_mode=0777,file_mode=0777

# 3. 자동 마운트
echo "//storageaccount.file.core.windows.net/ragdata /mnt/azure/rag-data cifs vers=3.0,username=storageaccount,password=storagekey,dir_mode=0777,file_mode=0777 0 0" | \
  sudo tee -a /etc/fstab
```

### Google Cloud Filestore

```bash
# 1. Filestore 마운트 (NFS)
sudo mkdir -p /mnt/gcs/rag-data

# 2. 마운트
sudo mount -t nfs 10.0.0.2:/rag_data /mnt/gcs/rag-data

# 3. 자동 마운트
echo "10.0.0.2:/rag_data /mnt/gcs/rag-data nfs defaults 0 0" | sudo tee -a /etc/fstab
```

---

## 📊 디렉토리 구조

```
/mnt/storage/rag-data/          # 외부 스토리지 마운트 포인트
├── milvus/                     # Milvus 벡터 데이터
│   ├── data/
│   ├── logs/
│   └── wal/
├── postgres/                   # PostgreSQL 데이터
│   ├── base/
│   ├── global/
│   ├── pg_wal/
│   └── ...
├── etcd/                       # etcd 메타데이터
│   └── member/
└── minio/                      # MinIO 객체 스토리지
    └── .minio.sys/
```

---

## 🚀 프로덕션 배포 순서

### 1단계: 스토리지 준비

```bash
# NFS 서버 설정 (스토리지 서버)
ssh storage-server
sudo mkdir -p /export/rag-data
sudo nano /etc/exports
# /export/rag-data 192.168.1.0/24(rw,sync,no_subtree_check)
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
```

### 2단계: Docker 호스트 설정

```bash
# NFS 마운트 (Docker 호스트)
ssh docker-host
sudo apt-get install -y nfs-common
sudo mkdir -p /mnt/storage/rag-data
sudo mount -t nfs storage-server:/export/rag-data /mnt/storage/rag-data

# 자동 마운트 설정
echo "storage-server:/export/rag-data /mnt/storage/rag-data nfs defaults 0 0" | \
  sudo tee -a /etc/fstab
```

### 3단계: Docker Compose 실행

```bash
cd 01.Docker_compose

# .env 파일 생성
cp .env.production .env
nano .env
# STORAGE_SERVER_PATH=/mnt/storage/rag-data 설정

# Docker Compose 실행
docker-compose -f docker-compose.production.yml up -d

# 상태 확인
docker-compose -f docker-compose.production.yml ps
```

---

## 🔍 마운트 확인 및 테스트

### 마운트 상태 확인

```bash
# 마운트 확인
df -h /mnt/storage/rag-data

# NFS 마운트 상세 정보
mount | grep nfs

# 쓰기 테스트
echo "test" > /mnt/storage/rag-data/test.txt
cat /mnt/storage/rag-data/test.txt
rm /mnt/storage/rag-data/test.txt
```

### 성능 테스트

```bash
# 쓰기 속도 테스트
dd if=/dev/zero of=/mnt/storage/rag-data/testfile bs=1M count=1024
# 1GB 파일 생성 속도 확인

# 읽기 속도 테스트
dd if=/mnt/storage/rag-data/testfile of=/dev/null bs=1M

# 정리
rm /mnt/storage/rag-data/testfile
```

---

## ⚡ 성능 최적화

### NFS 마운트 옵션 최적화

```bash
# /etc/fstab 최적화된 옵션
storage-server:/export/rag-data /mnt/storage/rag-data nfs \
  rw,hard,intr,rsize=1048576,wsize=1048576,timeo=600,retrans=2,_netdev 0 0

# 옵션 설명:
# - rsize=1048576: 읽기 버퍼 1MB
# - wsize=1048576: 쓰기 버퍼 1MB
# - hard: 네트워크 끊김 시 재시도
# - intr: 인터럽트 가능
# - timeo=600: 타임아웃 60초
# - _netdev: 네트워크 준비 후 마운트
```

### 네트워크 최적화

```bash
# 10Gbps 네트워크 권장
# NFS 서버와 Docker 호스트 간 전용 네트워크

# 네트워크 속도 테스트
iperf3 -s  # 스토리지 서버
iperf3 -c storage-server  # Docker 호스트

# 권장 속도:
# - 최소: 1Gbps
# - 권장: 10Gbps
# - 최적: 25Gbps+
```

---

## 🛡️ 보안 설정

### NFS 보안 강화

```bash
# /etc/exports 보안 옵션
/export/rag-data 192.168.1.50(rw,sync,no_subtree_check,root_squash,anonuid=1000,anongid=1000)

# 설명:
# - 192.168.1.50: 특정 IP만 허용 (Docker 호스트)
# - root_squash: root를 익명 사용자로 매핑 (보안)
# - anonuid/anongid: 익명 사용자 ID 지정
```

### 방화벽 설정

```bash
# NFS 서버 방화벽 (Ubuntu)
sudo ufw allow from 192.168.1.50 to any port nfs
sudo ufw allow from 192.168.1.50 to any port 2049

# CentOS/RHEL
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-source=192.168.1.50
sudo firewall-cmd --reload
```

---

## 💾 백업 전략

### 스토리지 서버에서 백업

```bash
# NFS 서버에서 직접 백업 (추천)
# /export/rag-data 폴더를 주기적으로 백업

# rsync로 백업
rsync -avz --progress /export/rag-data/ /backup/rag-data-$(date +%Y%m%d)/

# 스냅샷 (Btrfs/ZFS 사용 시)
btrfs subvolume snapshot /export/rag-data /snapshots/rag-data-$(date +%Y%m%d)
```

### 데이터베이스별 백업

```bash
# PostgreSQL 백업
docker-compose exec postgres pg_dump -U postgres rag_db_chatty > \
  /mnt/storage/backups/postgres_$(date +%Y%m%d).sql

# Milvus 컬렉션 백업
# Attu UI에서 또는 Milvus Backup 도구 사용
```

---

## 📈 용량 계획

### 예상 스토리지 사용량

```
파티션 10개 (각 300만 벡터):
├── Milvus: 180GB
│   └── 300만 × 1536차원 × 4바이트 × 10개 = 180GB
├── PostgreSQL: 75GB
│   └── 300만 행 × 2.5KB × 10개 = 75GB
├── etcd: 5GB
└── MinIO: 100GB

총: 360GB (여유 포함 500GB 권장)

파티션 100개 (각 300만 벡터):
총: 3.6TB (여유 포함 5TB 권장)
```

### 스토리지 타입별 권장 사양

| 파티션 수 | 데이터 크기 | 권장 스토리지 | 네트워크 |
|-----------|-------------|---------------|----------|
| 10개 | 500GB | NFS (1Gbps) | ✅ |
| 50개 | 2.5TB | NFS (10Gbps) | ✅ |
| 100개 | 5TB | NFS (10Gbps) | ⭐ |
| 500개+ | 25TB+ | NFS (25Gbps) + SSD | ⚡ |

---

## 🚨 트러블슈팅

### NFS 마운트 실패

```bash
# NFS 서비스 확인 (서버)
sudo systemctl status nfs-kernel-server

# 공유 목록 확인
showmount -e storage-server

# 권한 확인
ls -la /export/rag-data

# 로그 확인
sudo tail -f /var/log/syslog | grep nfs
```

### 성능 문제

```bash
# I/O 성능 확인
iostat -x 1

# NFS 통계
nfsstat -m

# 네트워크 지연 확인
ping storage-server
```

### 권한 문제

```bash
# Docker가 사용하는 UID/GID 확인
docker-compose exec milvus id

# 스토리지 권한 조정
sudo chown -R 1000:1000 /mnt/storage/rag-data
```

---

## ✅ 프로덕션 체크리스트

### 배포 전 확인사항

- [ ] NFS/SMB 서버 설정 완료
- [ ] 마운트 포인트 생성 및 테스트
- [ ] 자동 마운트 설정 (/etc/fstab)
- [ ] 디렉토리 권한 설정
- [ ] .env.production 파일 설정
- [ ] 방화벽 규칙 설정
- [ ] 백업 스크립트 설정
- [ ] 모니터링 설정

### 성능 확인

- [ ] 네트워크 속도 테스트 (최소 1Gbps)
- [ ] 디스크 I/O 테스트
- [ ] Docker Compose 실행 테스트
- [ ] 데이터 쓰기/읽기 테스트
- [ ] 파티션 로드 시간 측정

---

## 🎯 빠른 시작 (자동 스크립트)

```bash
# 1. 스토리지 자동 마운트
./mount-storage.sh

# 2. Docker Compose 실행
docker-compose -f docker-compose.production.yml --env-file .env.production up -d

# 3. 상태 확인
./status.sh
```

프로덕션 환경에서 외부 스토리지를 안전하게 사용할 수 있습니다! 🚀

