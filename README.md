# 🐳 Docker Compose 가이드

## 📦 포함된 서비스

| 서비스 | 포트 | 설명 |
|--------|------|------|
| **Milvus** | 19530 | 벡터 데이터베이스 (gRPC) |
| **Attu** | 3000 | Milvus 관리 UI |
| **PostgreSQL** | 5432 | 메타데이터 저장소 (파티셔닝 지원) |
| **etcd** | 2379 | Milvus 메타데이터 저장소 |
| **MinIO** | 9000, 9001 | Milvus 객체 스토리지 |

## 🚀 사용 방법

### 1. 개발/테스트 환경 실행

```bash
# 01.Docker_compose 폴더로 이동
cd 01.Docker_compose

# 개발 환경 시작 (8GB 캐시)
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 특정 서비스 로그만 확인
docker-compose logs -f milvus
docker-compose logs -f postgres
```

### 2. 프로덕션 환경 실행 (16코어 265GB 서버)

```bash
# 환경변수 설정
export STORAGE_SERVER_PATH=/mnt/storage/milvus-data
export POSTGRES_PASSWORD=your_secure_password

# 프로덕션 환경 시작 (160GB 캐시)
docker-compose -f docker-compose.production.yml up -d

# 로그 확인
docker-compose -f docker-compose.production.yml logs -f

# 상태 확인
docker-compose -f docker-compose.production.yml ps
```

### 2. 서비스 확인

```bash
# 실행 중인 컨테이너 확인
docker-compose ps

# 헬스 체크
docker-compose ps | grep healthy
```

### 3. 접속 정보

**Milvus:**
- gRPC: `localhost:19530`
- Metrics: `http://localhost:9091`

**Attu (Milvus UI):**
- URL: `http://localhost:3000`
- Milvus 연결: `localhost:19530`

**PostgreSQL:**
- Host: `localhost`
- Port: `5432`
- User: `postgres`
- Password: `password`
- Database: `rag_db_chatty`

**MinIO (Object Storage):**
- API: `http://localhost:9000`
- Console: `http://localhost:9001`
- Access Key: `minioadmin`
- Secret Key: `minioadmin`

### 4. 서비스 중지 및 삭제

#### 개발 환경
```bash
# 서비스 중지
docker-compose stop

# 서비스 중지 및 컨테이너 삭제
docker-compose down

# 볼륨까지 완전 삭제 (데이터 삭제 주의!)
docker-compose down -v
```

#### 프로덕션 환경
```bash
# 서비스 중지
docker-compose -f docker-compose.production.yml stop

# 서비스 중지 및 컨테이너 삭제
docker-compose -f docker-compose.production.yml down

# 볼륨까지 완전 삭제 (데이터 삭제 주의!)
docker-compose -f docker-compose.production.yml down -v
```

### 5. 데이터 초기화

```bash
# 볼륨 삭제 후 재시작 (완전 초기화)
docker-compose down -v
rm -rf volumes/  # 또는 폴더 수동 삭제
docker-compose up -d
```

## 📊 성능 설정

### Milvus 성능 설정

#### 개발/테스트 환경 (docker-compose.yml)
```yaml
environment:
  MILVUS_QUERYNODE_CACHE_SIZE: 8589934592      # 8GB (파티션 로드 캐시)
  MILVUS_DATANODE_SEGMENT_SIZE: 536870912       # 512MB (세그먼트 크기)
```

#### 프로덕션 환경 (docker-compose.production.yml)
```yaml
environment:
  MILVUS_QUERYNODE_CACHE_SIZE: 171798691840    # 160GB (대규모 환경용)
  MILVUS_DATANODE_SEGMENT_SIZE: 2147483648     # 2GB (대용량 데이터용)
  MILVUS_ROOTCOORD_DMLCHANNEL_NUM: 32          # 32개 (16코어 최적화)
```

**서버 사양별 권장 설정:**
- **8GB RAM**: 8GB 캐시 (파티션 10개 이하)
- **16GB RAM**: 16GB 캐시 (파티션 10-50개)
- **32GB RAM**: 32GB 캐시 (파티션 50-200개)
- **64GB RAM**: 64GB 캐시 (파티션 200-1000개)
- **265GB RAM**: 160GB 캐시 (파티션 4000개+ 대규모 환경)

### PostgreSQL 성능 설정

#### 개발/테스트 환경
```yaml
command:
  - shared_buffers=2GB           # 전체 메모리의 25%
  - effective_cache_size=6GB     # 전체 메모리의 50-75%
  - work_mem=64MB                # 정렬/해시 작업용
  - maintenance_work_mem=512MB   # VACUUM/인덱스 생성용
  - max_connections=200          # 최대 연결 수
```

#### 프로덕션 환경 (16코어 265GB 서버)
```yaml
command:
  - shared_buffers=10GB          # 40GB의 25%
  - effective_cache_size=30GB    # 40GB의 75%
  - work_mem=512MB               # 정렬/해시 작업용
  - maintenance_work_mem=4GB     # VACUUM/인덱스 생성용
  - max_connections=500          # 대용량 연결
  - max_wal_size=8GB             # WAL 크기 증가
```

**서버 메모리별 권장 설정:**
- 8GB RAM: `shared_buffers=2GB`, `effective_cache_size=6GB`
- 16GB RAM: `shared_buffers=4GB`, `effective_cache_size=12GB`
- 32GB RAM: `shared_buffers=8GB`, `effective_cache_size=24GB`
- 265GB RAM: `shared_buffers=10GB`, `effective_cache_size=30GB` (PostgreSQL 40GB 할당)

## 🔧 트러블슈팅

### Milvus 연결 실패

```bash
# Milvus 로그 확인
docker-compose logs milvus

# etcd 및 MinIO 상태 확인
docker-compose ps etcd minio

# 재시작
docker-compose restart milvus
```

### PostgreSQL 연결 실패

```bash
# PostgreSQL 로그 확인
docker-compose logs postgres

# PostgreSQL 접속 테스트
docker-compose exec postgres psql -U postgres -d rag_db_chatty

# 재시작
docker-compose restart postgres
```

### 메모리 부족

```bash
# Docker Desktop 메모리 설정 확인
# Settings > Resources > Memory

# 권장 메모리:
# - 최소: 8GB
# - 권장: 16GB
# - 최적: 32GB 이상
```

## 📁 볼륨 구조

### 개발/테스트 환경
```
01.Docker_compose/
├── volumes/
│   ├── etcd/           # etcd 데이터
│   ├── minio/          # MinIO (객체 스토리지)
│   ├── milvus/         # Milvus 벡터 데이터
│   └── postgres/       # PostgreSQL 데이터
├── docker-compose.yml
└── docker-compose.production.yml
```

### 프로덕션 환경 (외부 스토리지)
```
/mnt/storage/milvus-data/
├── etcd/               # etcd 메타데이터 (8GB 할당)
├── minio/              # MinIO 객체 스토리지
├── milvus/             # Milvus 벡터 데이터 (2TB+)
└── postgres/           # PostgreSQL 데이터 (500GB+)
```

## 🎯 초기 설정 순서

### 개발/테스트 환경
1. **Docker Compose 실행**
   ```bash
   docker-compose up -d
   ```

2. **PostgreSQL 스키마 생성** (자동 실행됨)
   - `migrations/init_chatty.sql` 자동 실행
   - `bot_registry`, `documents`, `document_chunks` 테이블 생성

3. **Milvus 컬렉션 생성** (API로 실행)
   ```bash
   POST http://localhost:8000/collection/create
   {
     "account_name": "chatty",
     "chat_bot_id": "550e8400-e29b-41d4-a716-446655440000",
     "bot_name": "테스트봇"
   }
   ```

4. **Attu에서 확인**
   - http://localhost:3000
   - Milvus 연결: `localhost:19530`
   - 생성된 컬렉션 확인

### 프로덕션 환경 (16코어 265GB 서버)
1. **외부 스토리지 마운트**
   ```bash
   # NFS 또는 로컬 스토리지 마운트
   sudo mount -t nfs storage-server:/mnt/data /mnt/storage/milvus-data
   ```

2. **프로덕션 환경 실행**
   ```bash
   export STORAGE_SERVER_PATH=/mnt/storage/milvus-data
   export POSTGRES_PASSWORD=your_secure_password
   docker-compose -f docker-compose.production.yml up -d
   ```

3. **성능 모니터링 설정**
   - Attu UI: http://localhost:3000
   - 메모리 사용률 모니터링
   - 파티션 로드/언로드 시간 측정

4. **대규모 컬렉션 생성**
   - 400개 컬렉션, 4000개 파티션 지원
   - 동시 로드 파티션: ~2000개
   - 예상 성능: 2000+ req/s

## 📊 리소스 사용량

### 개발/테스트 환경 메모리

| 서비스 | 기본 | 파티션 10개 로드 시 |
|--------|------|---------------------|
| etcd | 100MB | 100MB |
| MinIO | 200MB | 200MB |
| Milvus | 1GB | 8GB+ |
| PostgreSQL | 500MB | 2GB+ |
| Attu | 100MB | 100MB |
| **총** | **2GB** | **10GB+** |

### 프로덕션 환경 메모리 (16코어 265GB 서버)

| 서비스 | 기본 | 파티션 4000개 로드 시 |
|--------|------|----------------------|
| etcd | 200MB | 500MB |
| MinIO | 500MB | 1GB |
| Milvus | 2GB | 180GB |
| PostgreSQL | 1GB | 40GB |
| Attu | 100MB | 100MB |
| OS + 여유분 | 20GB | 35GB |
| **총** | **24GB** | **265GB** |

### 디스크

#### 개발/테스트 환경
| 서비스 | 초기 | 300만 벡터 × 10개 봇 |
|--------|------|---------------------|
| Milvus | 1GB | 180GB |
| PostgreSQL | 500MB | 75GB |
| MinIO | 500MB | 100GB |
| etcd | 100MB | 500MB |
| **총** | **2GB** | **355GB** |

#### 프로덕션 환경 (400개 컬렉션, 4000개 파티션)
| 서비스 | 초기 | 대규모 환경 |
|--------|------|------------|
| Milvus | 2GB | 2TB+ |
| PostgreSQL | 1GB | 500GB+ |
| MinIO | 1GB | 1TB+ |
| etcd | 200MB | 10GB |
| **총** | **4GB** | **3.5TB+** |

## ⚡ 빠른 시작

### 개발/테스트 환경
```bash
# 1. Docker Compose 실행
cd 01.Docker_compose
docker-compose up -d

# 2. 서비스 상태 확인 (모두 healthy 대기)
docker-compose ps

# 3. Attu 접속
# 브라우저: http://localhost:3000

# 4. FastAPI 서버 실행 (프로젝트 루트에서)
cd ..
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 5. API 문서 확인
# 브라우저: http://localhost:8000/docs
```

### 프로덕션 환경 (16코어 265GB 서버)
```bash
# 1. 환경변수 설정
export STORAGE_SERVER_PATH=/mnt/storage/milvus-data
export POSTGRES_PASSWORD=your_secure_password

# 2. 프로덕션 환경 시작
cd 01.Docker_compose
docker-compose -f docker-compose.production.yml up -d

# 3. 서비스 상태 확인 (모두 healthy 대기)
docker-compose -f docker-compose.production.yml ps

# 4. Attu 접속
# 브라우저: http://localhost:3000

# 5. 성능 모니터링
# - 메모리 사용률: 80% 이하 유지
# - 로드/언로드 시간: 평균 5초 이하
# - 동시 쿼리 처리량: 2000+ req/s
```

## 🛑 서비스 종료

### 개발 환경
```bash
# 서비스 중지 (데이터 유지)
docker-compose stop

# 서비스 삭제 (데이터 유지)
docker-compose down

# 완전 삭제 (데이터 포함)
docker-compose down -v
rm -rf volumes/
```

### 프로덕션 환경
```bash
# 서비스 중지 (데이터 유지)
docker-compose -f docker-compose.production.yml stop

# 서비스 삭제 (데이터 유지)
docker-compose -f docker-compose.production.yml down

# 완전 삭제 (데이터 포함) - 주의!
docker-compose -f docker-compose.production.yml down -v
# 외부 스토리지 데이터도 수동 삭제 필요
```

