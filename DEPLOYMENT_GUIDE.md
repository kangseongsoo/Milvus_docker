# 🚀 배포 가이드: 테스트 vs 운영

## 📋 목차

1. [테스트 환경 구성](#테스트-환경)
2. [운영 서버 구성 방안](#운영-서버-구성)
3. [아키텍처 비교](#아키텍처-비교)
4. [마이그레이션 가이드](#마이그레이션)

---

## 🧪 테스트 환경

### 구성
```
단일 서버 (All-in-One)
├── Docker Compose
│   ├── Milvus (19530)
│   ├── PostgreSQL (5432)
│   ├── Attu (3000)
│   ├── etcd
│   └── MinIO
└── FastAPI (8000)

리소스:
- CPU: 8-16 코어
- RAM: 32GB
- Disk: 500GB SSD
```

### 실행 방법

```bash
# 테스트 환경 시작
cd 01.Docker_compose
docker-compose up -d

# FastAPI 실행
cd ..
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 용도
- ✅ 개발 및 테스트
- ✅ 소규모 데이터 (파티션 1-10개)
- ✅ 프로토타이핑
- ✅ CI/CD 테스트

---

## 🏢 운영 서버 구성

### 방안 1: 단일 서버 (Small-Medium Scale) ⭐ 권장 (시작)

**구성:**
```
단일 고성능 서버
├── Docker Compose
│   ├── Milvus
│   ├── PostgreSQL
│   ├── Attu
│   ├── etcd
│   └── MinIO
├── FastAPI (Docker 또는 직접 실행)
└── 외부 스토리지 (NFS 마운트)

리소스:
- CPU: 32-64 코어
- RAM: 128-256GB
- Disk: 2TB NVMe SSD (OS/캐시)
- Storage: 10-50TB NFS (데이터)
```

**장점:**
- ✅ 구성 간단
- ✅ 관리 용이
- ✅ 비용 효율적
- ✅ 파티션 50개까지 충분

**적용 시나리오:**
```
데이터 규모:
- 파티션: 10-50개
- 총 데이터: 3억-15억 벡터
- 총 용량: 500GB - 2.5TB

성능:
- 검색 속도: 15-20ms
- 동시 요청: 100-500 req/s
```

**docker-compose.yml:**
```yaml
# 이미 작성된 docker-compose.production.yml 사용
# 외부 스토리지 마운트만 설정
```

---

### 방안 2: 서비스 분리 (Medium-Large Scale) 🏆 권장 (확장)

**구성:**
```
┌─────────────────────────────────────────┐
│ 서버 1: FastAPI (API 서버)               │
│ - FastAPI 인스턴스 × 4                   │
│ - 임베딩 처리                             │
│ - Load Balancer (Nginx)                 │
│ - CPU: 16코어, RAM: 32GB                │
└─────────────────────────────────────────┘
            ↓ ↓ ↓
┌─────────────────────────────────────────┐
│ 서버 2: Milvus (벡터 DB)                 │
│ - Milvus Standalone                     │
│ - etcd, MinIO                           │
│ - CPU: 32코어, RAM: 256GB               │
│ - Disk: 2TB NVMe (캐시)                 │
└─────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────┐
│ 서버 3: PostgreSQL (메타데이터)          │
│ - PostgreSQL 15                         │
│ - CPU: 16코어, RAM: 64GB                │
│ - Disk: 1TB NVMe                        │
└─────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────┐
│ 스토리지 서버: NFS                       │
│ - 대용량 스토리지 (10-50TB)              │
│ - RAID 6/10 (안정성)                    │
│ - 10Gbps 네트워크                        │
└─────────────────────────────────────────┘
```

**장점:**
- ✅ 확장성 우수
- ✅ 각 서비스 독립적 스케일링
- ✅ 고가용성 구현 가능
- ✅ 성능 최적화

**적용 시나리오:**
```
데이터 규모:
- 파티션: 50-500개
- 총 데이터: 15억-150억 벡터
- 총 용량: 2.5TB - 25TB

성능:
- 검색 속도: 15ms
- 동시 요청: 500-2000 req/s
```

---

### 방안 3: Kubernetes (Large Scale) 🚀 엔터프라이즈

**구성:**
```
Kubernetes Cluster
├── FastAPI Pods (Auto-scaling)
│   ├── Pod 1-10 (동적)
│   └── HPA (Horizontal Pod Autoscaler)
│
├── Milvus Cluster
│   ├── Query Nodes × 3
│   ├── Data Nodes × 3
│   ├── Index Nodes × 2
│   └── Root Coord
│
├── PostgreSQL HA
│   ├── Primary
│   ├── Standby × 2
│   └── pgpool (Load Balancer)
│
└── Persistent Volumes
    ├── NFS Provisioner
    └── StorageClass
```

**장점:**
- ✅ 자동 스케일링
- ✅ 고가용성 (HA)
- ✅ 무중단 배포
- ✅ 무제한 확장

**적용 시나리오:**
```
데이터 규모:
- 파티션: 500개+
- 총 데이터: 150억+ 벡터
- 총 용량: 25TB+

성능:
- 검색 속도: 10-15ms
- 동시 요청: 2000+ req/s
```

---

## 🎯 운영 서버 구성 권장사항

### Phase 1: 시작 단계 (단일 서버)

```yaml
# docker-compose.production.yml 사용

서버 사양:
- CPU: 32코어
- RAM: 128GB
- SSD: 2TB NVMe (캐시)
- Storage: 10TB NFS

예상 비용: $500-1000/월 (베어메탈)

확장 가능:
- 파티션 50개까지
- 15억 벡터까지
```

### Phase 2: 성장 단계 (서비스 분리)

```yaml
서버 구성:
1. FastAPI 서버 (16코어, 32GB) × 1-2대
2. Milvus 서버 (32코어, 256GB) × 1대
3. PostgreSQL 서버 (16코어, 64GB) × 1대
4. NFS 스토리지 (50TB) × 1대

예상 비용: $2000-3000/월

확장 가능:
- 파티션 500개까지
- 150억 벡터까지
```

### Phase 3: 엔터프라이즈 (Kubernetes)

```yaml
Kubernetes 클러스터:
- Worker Nodes: 10-20대
- Master Nodes: 3대
- Storage: Ceph/GlusterFS (100TB+)

예상 비용: $10,000+/월

확장 가능:
- 무제한
```

---

## 📁 디렉토리 구조 (운영)

### 외부 스토리지 구조

```
/mnt/storage/rag-data/              # NFS 마운트 포인트
├── milvus/                         # Milvus 데이터
│   ├── data/
│   │   ├── collection_chatty/
│   │   │   ├── bot_550e8400.../   # 파티션 데이터
│   │   │   ├── bot_7c9e6679.../
│   │   │   └── ...
│   │   └── indexes/
│   ├── logs/
│   └── wal/
│
├── postgres/                       # PostgreSQL 데이터
│   ├── base/
│   │   └── rag_db_chatty/
│   │       ├── documents_550e8400.../  # 파티션 테이블
│   │       ├── documents_7c9e6679.../
│   │       └── ...
│   ├── pg_wal/
│   └── pg_log/
│
├── etcd/                           # etcd 메타데이터
│   └── member/
│
├── minio/                          # MinIO 객체 스토리지
│   └── .minio.sys/
│
└── backups/                        # 백업 디렉토리
    ├── daily/
    ├── weekly/
    └── monthly/
```

---

## 🐳 운영 서버 Docker Compose 구성

### 서비스 분리형 (권장)

**서버 1: FastAPI**
```yaml
# docker-compose.fastapi.yml
version: '3.8'

services:
  fastapi:
    container_name: rag-fastapi
    build:
      context: ../
      dockerfile: Dockerfile
    environment:
      - MILVUS_HOST=milvus-server.internal  # Milvus 서버 주소
      - POSTGRES_HOST=postgres-server.internal
    ports:
      - "8000:8000"
    restart: unless-stopped
    deploy:
      replicas: 4  # 4개 인스턴스
      resources:
        limits:
          cpus: '4'
          memory: 8G
```

**서버 2: Milvus**
```yaml
# docker-compose.milvus.yml
version: '3.8'

services:
  etcd:
    # ... etcd 설정
    volumes:
      - /mnt/storage/rag-data/etcd:/etcd

  minio:
    # ... minio 설정
    volumes:
      - /mnt/storage/rag-data/minio:/minio_data

  milvus:
    # ... milvus 설정
    volumes:
      - /mnt/storage/rag-data/milvus:/var/lib/milvus
    ports:
      - "19530:19530"  # 외부 접속 허용
```

**서버 3: PostgreSQL**
```yaml
# docker-compose.postgres.yml
version: '3.8'

services:
  postgres:
    # ... postgres 설정
    volumes:
      - /mnt/storage/rag-data/postgres:/var/lib/postgresql/data
    ports:
      - "5432:5432"  # 외부 접속 허용
```

---

## 🔐 보안 설정 (운영)

### 1. 네트워크 격리

```yaml
# 프라이빗 네트워크 사용
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # 외부 접속 차단

services:
  fastapi:
    networks:
      - frontend
      - backend
  
  milvus:
    networks:
      - backend  # 내부 네트워크만
  
  postgres:
    networks:
      - backend  # 내부 네트워크만
```

### 2. 접근 제어

```yaml
# PostgreSQL
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}  # 강력한 비밀번호
  POSTGRES_HOST_AUTH_METHOD: md5           # 비밀번호 인증 필수

# Milvus
# API 키 또는 OAuth 추가
```

### 3. SSL/TLS 적용

```yaml
# FastAPI에 SSL 인증서 적용
fastapi:
  volumes:
    - /etc/letsencrypt:/etc/letsencrypt:ro
  command: >
    uvicorn app.main:app
    --host 0.0.0.0
    --port 443
    --ssl-keyfile /etc/letsencrypt/live/domain.com/privkey.pem
    --ssl-certfile /etc/letsencrypt/live/domain.com/fullchain.pem
```

---

## 🏗️ 운영 서버 권장 아키텍처

### 옵션 A: 단일 서버 + 외부 스토리지 (소규모)

```
┌─────────────────────────────────────────┐
│ 운영 서버 (32코어, 128GB RAM)            │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ Docker Compose                   │  │
│  │ ├── FastAPI (:8000)              │  │
│  │ ├── Milvus (:19530)              │  │
│  │ ├── PostgreSQL (:5432)           │  │
│  │ ├── Attu (:3000)                 │  │
│  │ ├── etcd                         │  │
│  │ └── MinIO                        │  │
│  └──────────────────────────────────┘  │
│         ↓ (데이터 저장)                 │
└─────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────┐
│ NFS 스토리지 서버 (10-50TB)             │
│ /export/rag-data/                       │
│ ├── milvus/ (벡터 데이터)               │
│ ├── postgres/ (메타데이터)              │
│ └── backups/ (백업)                     │
└─────────────────────────────────────────┘

예상 비용: $1,000-2,000/월
지원 규모: 파티션 50개, 15억 벡터
```

**Docker Compose 파일:**
```yaml
# docker-compose.production.yml 사용
# STORAGE_SERVER_PATH=/mnt/storage/rag-data
```

**실행:**
```bash
# 1. NFS 마운트
./mount-storage.sh

# 2. Docker Compose 실행
docker-compose -f docker-compose.production.yml up -d
```

---

### 옵션 B: 서비스 분리 (중대규모) ⭐ 권장 (확장)

```
┌─────────────────────────────────────┐
│ 서버 1-2: FastAPI (16코어, 32GB)     │
│ - Nginx Load Balancer               │
│ - FastAPI × 4 인스턴스               │
│ - 임베딩 처리                         │
└─────────────────────────────────────┘
         ↓ (요청)
┌─────────────────────────────────────┐
│ 서버 3: Milvus (64코어, 512GB)       │
│ - Milvus Standalone                 │
│ - etcd, MinIO                       │
│ - 300만 × 100개 파티션 = 30억 벡터   │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 서버 4: PostgreSQL (32코어, 128GB)   │
│ - PostgreSQL 15 (파티셔닝)          │
│ - 100개 파티션                       │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 스토리지 서버: NFS (50TB)            │
│ - RAID 6/10                         │
│ - 10Gbps 네트워크                    │
│ - 자동 백업                          │
└─────────────────────────────────────┘

예상 비용: $5,000-8,000/월
지원 규모: 파티션 100-500개, 30억-150억 벡터
```

**각 서버별 Docker Compose:**

**서버 1 (FastAPI):**
```yaml
# docker-compose.fastapi.yml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - fastapi

  fastapi:
    build: ../
    environment:
      MILVUS_HOST: 192.168.1.101  # Milvus 서버 IP
      POSTGRES_HOST: 192.168.1.102  # PostgreSQL 서버 IP
    deploy:
      replicas: 4
```

**서버 2 (Milvus):**
```yaml
# docker-compose.milvus.yml
version: '3.8'

services:
  etcd:
    # ...
    volumes:
      - /mnt/storage/rag-data/etcd:/etcd

  minio:
    # ...
    volumes:
      - /mnt/storage/rag-data/minio:/minio_data

  milvus:
    # ...
    volumes:
      - /mnt/storage/rag-data/milvus:/var/lib/milvus
    ports:
      - "0.0.0.0:19530:19530"  # 모든 네트워크에서 접속
```

**서버 3 (PostgreSQL):**
```yaml
# docker-compose.postgres.yml
version: '3.8'

services:
  postgres:
    # ...
    volumes:
      - /mnt/storage/rag-data/postgres:/var/lib/postgresql/data
    ports:
      - "0.0.0.0:5432:5432"
```

---

### 옵션 C: Kubernetes + Helm (엔터프라이즈)

```
Kubernetes Cluster (10-20 Nodes)
├── Namespace: rag-production
│   ├── FastAPI Deployment (HPA)
│   ├── Milvus Cluster (Helm Chart)
│   ├── PostgreSQL HA (Operator)
│   └── Ingress (HTTPS)
│
└── Storage
    ├── PersistentVolume (NFS/Ceph)
    └── StorageClass (동적 프로비저닝)

예상 비용: $10,000+/월
지원 규모: 무제한
```

---

## 📊 구성 비교표

| 항목 | 테스트 | 단일 서버 | 서비스 분리 | Kubernetes |
|------|--------|----------|------------|------------|
| **서버 수** | 1 | 1-2 | 4-5 | 10+ |
| **CPU** | 8코어 | 32코어 | 128코어 | 무제한 |
| **RAM** | 32GB | 128GB | 512GB+ | 무제한 |
| **스토리지** | 500GB | 10TB | 50TB | 무제한 |
| **파티션** | 1-10 | 10-50 | 50-500 | 무제한 |
| **동시 요청** | 10-50 | 100-500 | 500-2000 | 무제한 |
| **고가용성** | ❌ | ⚠️ | ✅ | ✅ |
| **자동 확장** | ❌ | ❌ | ⚠️ | ✅ |
| **비용/월** | $100 | $1,000 | $5,000 | $10,000+ |
| **복잡도** | 낮음 | 중간 | 높음 | 매우 높음 |
| **권장 시기** | 개발 | 시작 | 성장 | 대규모 |

---

## 🎯 단계별 마이그레이션 전략

### 1단계: 테스트 환경 (지금)

```bash
# 로컬 Docker Compose
docker-compose up -d

목적: 개발 및 테스트
기간: 1-3개월
```

### 2단계: 단일 서버 운영 (초기 런칭)

```bash
# 운영 서버 + 외부 스토리지
docker-compose -f docker-compose.production.yml up -d

목적: 서비스 시작
예상 사용자: 1,000-10,000명
기간: 3-12개월
```

### 3단계: 서비스 분리 (성장기)

```bash
# 각 서버에 개별 Docker Compose
서버1: FastAPI
서버2: Milvus
서버3: PostgreSQL
서버4: NFS Storage

목적: 확장성 확보
예상 사용자: 10,000-100,000명
기간: 1-2년
```

### 4단계: Kubernetes (성숙기)

```bash
# Kubernetes 클러스터
helm install milvus milvus/milvus
helm install postgresql bitnami/postgresql-ha

목적: 무제한 확장
예상 사용자: 100,000+명
```

---

## 🚀 빠른 시작 (운영 서버)

### 단일 서버 구성

```bash
# 1. NFS 스토리지 마운트
cd 01.Docker_compose
sudo ./mount-storage.sh
# NFS 선택 → 스토리지 서버 IP 입력

# 2. 환경변수 설정
cp .env.production .env
nano .env
# STORAGE_SERVER_PATH=/mnt/storage/rag-data 확인

# 3. Docker Compose 실행
docker-compose -f docker-compose.production.yml up -d

# 4. 상태 확인
./status.sh

# 5. 백업 설정
crontab -e
# 0 2 * * * /path/to/01.Docker_compose/backup.sh
```

---

## 📊 모니터링 (운영 필수)

### Prometheus + Grafana 추가

```yaml
# docker-compose.monitoring.yml
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - /mnt/storage/rag-data/prometheus:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    volumes:
      - /mnt/storage/rag-data/grafana:/var/lib/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

---

## ✅ 권장 시작 전략

### 현재 상황 → 단일 서버 운영 (Phase 1)

```
1. 테스트 환경 (로컬)
   └── docker-compose.yml 사용
   └── 데이터 규모 검증

2. 운영 서버 (단일 서버 + NFS)
   └── docker-compose.production.yml 사용
   └── 외부 스토리지 연동
   └── 파티션 50개까지 지원

3. 확장 시점 (파티션 50개 초과)
   └── 서비스 분리 검토
   └── Milvus 전용 서버 구성
```

**핵심**: 처음부터 복잡하게 구성하지 말고, **단일 서버로 시작**해서 필요시 단계적으로 확장! 🚀

현재는 **docker-compose.production.yml + NFS 스토리지**로 시작하는 것을 강력히 권장합니다!

