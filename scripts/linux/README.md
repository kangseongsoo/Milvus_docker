# 🐧 Rocky Linux 운영 환경 - 실행 가이드

Rocky Linux 서버에서 Milvus + PostgreSQL RAG 시스템을 운영하기 위한 스크립트 모음입니다.

## 📁 폴더 구조

```
linux/
├── install-dependencies.sh    # 초기 설치 (Docker, Docker Compose)
├── setup-permissions.sh        # 스크립트 실행 권한 설정
├── dev/                        # 개발/테스트 환경
│   ├── start.sh
│   ├── stop.sh
│   ├── reset.sh
│   ├── logs.sh
│   └── status.sh
└── production/                 # 운영 환경 (외부 스토리지)
    ├── start-prod.sh
    ├── stop-prod.sh
    ├── status-prod.sh
    ├── backup-prod.sh
    └── mount-storage.sh
```

## 🚀 초기 설정 (최초 1회만)

### 1. 의존성 설치
```bash
cd scripts/linux
sudo ./install-dependencies.sh
```

**설치 항목:**
- Docker Engine
- Docker Compose
- 필요한 시스템 패키지

**설치 후 로그아웃/로그인 필요!**

### 2. 스크립트 실행 권한 설정
```bash
./setup-permissions.sh
```

## 🔷 개발/테스트 환경 (dev/)

로컬 스토리지를 사용하는 개발 및 테스트 환경입니다.

### 서비스 시작
```bash
cd dev/
./start.sh
```

### 서비스 중지
```bash
./stop.sh
```

### 상태 확인
```bash
./status.sh
```

### 로그 확인
```bash
# 전체 로그
./logs.sh

# 특정 서비스
./logs.sh milvus
./logs.sh postgres
```

### 완전 초기화
```bash
./reset.sh
```

**데이터 저장 위치:** `./volumes/` (로컬 디렉토리)

---

## 🔶 프로덕션 환경 (production/)

외부 스토리지 서버를 사용하는 운영 환경입니다.

### 1단계: 외부 스토리지 마운트

```bash
cd production/
./mount-storage.sh
```

**지원 스토리지 타입:**
- NFS (Network File System)
- SMB/CIFS (Windows 공유)
- 로컬 디스크

**마운트 예시:**
```bash
# NFS 스토리지
# 서버: 192.168.1.100
# 경로: /export/rag-data
# 마운트: /mnt/storage/rag-data
```

### 2단계: 환경 변수 설정

`.env` 파일 생성 (프로젝트 루트):
```bash
cd ../../../../  # 프로젝트 루트로
nano .env
```

`.env` 파일 내용:
```env
# 스토리지 경로
STORAGE_SERVER_PATH=/mnt/storage/rag-data

# PostgreSQL 설정
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_DB=rag_db_chatty
```

**또는 환경 변수 직접 설정:**
```bash
export STORAGE_SERVER_PATH=/mnt/storage/rag-data
export POSTGRES_PASSWORD=your_secure_password
```

### 3단계: 서비스 시작

```bash
cd scripts/linux/production/
./start-prod.sh
```

### 서비스 관리

#### 상태 확인
```bash
./status-prod.sh
```

출력 내용:
- 컨테이너 상태
- 헬스 체크
- 리소스 사용량 (CPU, 메모리)
- 스토리지 사용량
- 네트워크 정보

#### 서비스 중지
```bash
./stop-prod.sh
```

#### 데이터 백업
```bash
./backup-prod.sh
```

**백업 저장 위치:** `/var/backups/milvus-rag/YYYYMMDD_HHMMSS/`

**백업 항목:**
- PostgreSQL 덤프 (SQL)
- Milvus 데이터
- PostgreSQL 데이터 파일
- MinIO 데이터
- etcd 데이터

**자동 정리:** 30일 이상 된 백업 자동 삭제

## 📍 접속 정보

### 서비스 URL

| 서비스 | URL/주소 | 포트 |
|--------|---------|------|
| Milvus gRPC | `서버IP:19530` | 19530 |
| Attu UI | `http://서버IP:3000` | 3000 |
| PostgreSQL | `서버IP:5432` | 5432 |
| MinIO Console | `http://서버IP:9001` | 9001 |
| MinIO API | `http://서버IP:9000` | 9000 |

### 방화벽 설정 (필요시)

```bash
# FirewallD 사용 시
sudo firewall-cmd --permanent --add-port=19530/tcp  # Milvus
sudo firewall-cmd --permanent --add-port=3000/tcp   # Attu
sudo firewall-cmd --permanent --add-port=5432/tcp   # PostgreSQL
sudo firewall-cmd --permanent --add-port=9000-9001/tcp  # MinIO
sudo firewall-cmd --reload
```

## 💾 스토리지 구조

```
$STORAGE_SERVER_PATH/
├── milvus/      # Milvus 벡터 데이터
├── postgres/    # PostgreSQL 데이터
├── etcd/        # Milvus 메타데이터
└── minio/       # MinIO 객체 스토리지
```

## 🔧 문제 해결

### 스토리지 마운트 실패
```bash
# 마운트 상태 확인
df -h | grep rag-data

# 수동 마운트 (NFS 예시)
sudo mount -t nfs 192.168.1.100:/export/rag-data /mnt/storage/rag-data
```

### 컨테이너 시작 실패
```bash
# 로그 확인
cd ../../../  # 프로젝트 루트
docker-compose -f docker-compose.production.yml logs -f

# 개별 컨테이너 로그
docker logs milvus-standalone
docker logs rag-postgres
```

### 권한 문제
```bash
# 스토리지 경로 권한 확인
ls -la $STORAGE_SERVER_PATH

# 권한 수정
sudo chown -R $USER:$USER $STORAGE_SERVER_PATH
```

### 포트 충돌
```bash
# 포트 사용 확인
sudo netstat -tlnp | grep -E '19530|5432|3000|9000|9001'

# 프로세스 종료
sudo kill -9 <PID>
```

## 📊 모니터링

### 실시간 리소스 사용량
```bash
cd production/
watch -n 2 './status-prod.sh'
```

### Docker 시스템 정보
```bash
docker system df
docker stats
```

### 로그 모니터링
```bash
cd ../../../  # 프로젝트 루트
docker-compose -f docker-compose.production.yml logs -f --tail=100
```

## 🔄 정기 유지보수

### 일일 작업
```bash
# 상태 확인
./status-prod.sh
```

### 주간 작업
```bash
# 백업 수행
./backup-prod.sh

# 로그 정리 (옵션)
docker-compose -f docker-compose.production.yml logs --tail=0 > /dev/null
```

### 월간 작업
```bash
# Docker 시스템 정리
docker system prune -a --volumes

# 사용하지 않는 이미지 정리
docker image prune -a
```

## 🚨 재해 복구

### 데이터 복원
```bash
# 1. 서비스 중지
./stop-prod.sh

# 2. 백업에서 복원
BACKUP_DIR="/var/backups/milvus-rag/YYYYMMDD_HHMMSS"
rsync -az $BACKUP_DIR/* $STORAGE_SERVER_PATH/

# 3. 서비스 시작
./start-prod.sh
```

### PostgreSQL 덤프 복원
```bash
cd ../../../
docker-compose -f docker-compose.production.yml exec -T postgres \
  psql -U postgres rag_db_chatty < backup/postgres_dump.sql
```

## 🔐 보안 권장사항

1. **비밀번호 변경**: `.env` 파일의 기본 비밀번호 변경
2. **방화벽 설정**: 필요한 포트만 개방
3. **정기 백업**: 크론잡으로 자동 백업 설정
4. **로그 모니터링**: 이상 징후 감지
5. **업데이트**: 정기적으로 Docker 이미지 업데이트

## 📝 크론잡 설정 예시

```bash
# crontab 편집
crontab -e

# 매일 새벽 2시 백업
0 2 * * * cd /path/to/scripts/linux/production && ./backup-prod.sh >> /var/log/milvus-backup.log 2>&1

# 매시간 상태 체크
0 * * * * cd /path/to/scripts/linux/production && ./status-prod.sh >> /var/log/milvus-status.log 2>&1
```

## 💡 성능 튜닝

### Milvus 성능 설정
`docker-compose.production.yml` 참조:
- Query Cache: 16GB
- Segment Size: 512MB
- DML Channels: 16

### PostgreSQL 성능 설정
- Shared Buffers: 8GB
- Effective Cache: 24GB
- Work Memory: 256MB

### 리소스 제한
- Milvus: 최대 64GB RAM, 32 CPU
- PostgreSQL: 최대 32GB RAM, 16 CPU

## 📞 지원

문제 발생 시:
1. 로그 확인: `./status-prod.sh`
2. Docker 로그: `docker-compose logs`
3. 시스템 로그: `journalctl -u docker`

## 🔗 관련 문서

- `../../../docker-compose.production.yml` - 프로덕션 설정
- `../../../DEPLOYMENT_GUIDE.md` - 배포 가이드
- `../../../STORAGE_SETUP.md` - 스토리지 설정 상세

