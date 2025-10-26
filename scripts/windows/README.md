# 🪟 Windows 개발 환경 - 실행 가이드

Windows 로컬 개발 환경에서 Milvus + PostgreSQL RAG 시스템을 실행하는 스크립트 모음입니다.

## 📋 사전 요구사항

- Windows 10/11
- Docker Desktop for Windows 설치 및 실행 중
- PowerShell 5.1 이상

## 🚀 빠른 시작

### 1. 서비스 시작
```powershell
.\start.ps1
```

**실행 내용:**
- `docker-compose.yml` 파일로 모든 서비스 시작
- etcd, MinIO, Milvus, PostgreSQL, Attu 컨테이너 실행
- 데이터는 `./volumes/` 폴더에 로컬 저장

### 2. 서비스 중지
```powershell
.\stop.ps1
```

**실행 내용:**
- 모든 컨테이너 중지 (데이터는 유지됨)

### 3. 로그 확인
```powershell
# 전체 로그
.\logs.ps1

# 특정 서비스 로그만
.\logs.ps1 milvus
.\logs.ps1 postgres
.\logs.ps1 attu
```

### 4. 완전 초기화 (데이터 삭제)
```powershell
.\reset.ps1
```

**⚠️ 경고:** 모든 데이터가 삭제됩니다! 확인 후 실행됩니다.

## 📍 접속 정보

서비스 시작 후 다음 URL로 접속할 수 있습니다:

| 서비스 | URL/주소 | 용도 |
|--------|---------|------|
| **Milvus gRPC** | `localhost:19530` | 벡터 DB 연결 |
| **Attu (Milvus UI)** | http://localhost:3000 | Milvus 관리 콘솔 |
| **PostgreSQL** | `localhost:5432` | 메타데이터 DB |
| **MinIO Console** | http://localhost:9001 | 객체 스토리지 관리 |

### PostgreSQL 접속 정보
- **Host:** localhost
- **Port:** 5432
- **Database:** rag_db_chatty
- **Username:** postgres
- **Password:** dktkekf0215@#

### MinIO 접속 정보
- **Console:** http://localhost:9001
- **Access Key:** minioadmin
- **Secret Key:** minioadmin

## 💾 데이터 저장 위치

모든 데이터는 프로젝트 루트의 `volumes/` 폴더에 저장됩니다:

```
volumes/
├── etcd/          # Milvus 메타데이터
├── minio/         # 벡터 데이터 및 인덱스
├── milvus/        # Milvus 내부 데이터
└── postgres/      # PostgreSQL 데이터
```

## 🔧 문제 해결

### Docker Desktop이 실행 중이지 않음
```powershell
# Docker Desktop 상태 확인
docker ps
```

Docker Desktop을 시작하고 다시 시도하세요.

### 포트 충돌 오류
다음 포트가 이미 사용 중인지 확인:
- 19530 (Milvus)
- 5432 (PostgreSQL)
- 3000 (Attu)
- 9000, 9001 (MinIO)

사용 중인 프로세스 종료 또는 `docker-compose.yml`에서 포트 변경

### 컨테이너가 계속 재시작됨
```powershell
# 로그 확인
.\logs.ps1 milvus

# 컨테이너 상태 확인
docker-compose ps
```

### 디스크 공간 부족
```powershell
# Docker 시스템 정리
docker system prune -a

# 완전 초기화 후 재시작
.\reset.ps1
.\start.ps1
```

## 🔄 일반적인 워크플로우

### 개발 시작
```powershell
cd C:\DEVELOP\Milvus_docker\scripts\windows
.\start.ps1
```

### 개발 종료
```powershell
.\stop.ps1
```

### 문제 발생 시 재시작
```powershell
.\stop.ps1
.\start.ps1
.\logs.ps1  # 문제 확인
```

### 클린 재시작
```powershell
.\reset.ps1
.\start.ps1
```

## 📝 참고사항

- 개발 환경이므로 리소스 제한이 없습니다
- 데이터는 로컬 볼륨에 저장되므로 백업이 중요합니다
- 프로덕션 배포 시에는 `docker-compose.production.yml` 사용

## 🔗 관련 파일

- `../../docker-compose.yml` - 개발 환경 설정
- `../../docker-compose.production.yml` - 프로덕션 환경 설정

## 💡 다음 단계

서비스 시작 후:

1. **Attu 접속**: http://localhost:3000
2. **Milvus 컬렉션 생성**: Attu UI에서 관리
3. **FastAPI 서버 시작**: 상위 프로젝트에서 백엔드 실행
4. **애플리케이션 개발**: `localhost:19530`으로 Milvus 연결

## 📞 도움말

문제가 발생하면 로그를 확인하세요:
```powershell
.\logs.ps1
```

