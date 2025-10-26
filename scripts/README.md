# 📜 스크립트 실행 가이드

환경별로 구분된 실행 스크립트 디렉토리입니다.

## 📁 폴더 구조

```
scripts/
├── windows/              # 🪟 Windows 개발 환경
│   ├── start.ps1
│   ├── stop.ps1
│   ├── reset.ps1
│   ├── logs.ps1
│   └── README.md
│
└── linux/                # 🐧 Rocky Linux 운영 환경
    ├── dev/              # 개발/테스트용
    │   ├── start.sh
    │   ├── stop.sh
    │   ├── reset.sh
    │   ├── logs.sh
    │   └── status.sh
    │
    ├── production/       # 운영용 (외부 스토리지)
    │   ├── start-prod.sh
    │   ├── stop-prod.sh
    │   ├── status-prod.sh
    │   ├── backup-prod.sh
    │   └── mount-storage.sh
    │
    ├── install-dependencies.sh
    ├── setup-permissions.sh
    └── README.md
```

## 🚀 빠른 시작

### Windows (로컬 개발)
```powershell
cd scripts\windows
.\start.ps1
```

### Linux 개발/테스트
```bash
cd scripts/linux/dev
./start.sh
```

### Linux 프로덕션
```bash
cd scripts/linux/production
./mount-storage.sh    # 최초 1회
./start-prod.sh
```

## 📖 상세 가이드

각 환경별 상세한 사용법은 해당 폴더의 README를 참조하세요:

- **Windows**: [windows/README.md](./windows/README.md)
- **Linux**: [linux/README.md](./linux/README.md)

## 🔧 환경별 특징

### Windows 개발 환경
- Docker Desktop 사용
- 로컬 볼륨 저장 (`./volumes/`)
- PowerShell 스크립트
- 개발 및 테스트 용도

### Linux 개발 환경
- Docker Engine 사용
- 로컬 볼륨 저장 (`./volumes/`)
- Bash 스크립트
- 서버 테스트 용도

### Linux 프로덕션 환경
- 외부 스토리지 서버 사용
- 리소스 제한 설정
- 자동 재시작 정책
- 백업 스크립트 포함
- 운영 환경 전용

## 📋 스크립트 기능 비교

| 기능 | Windows | Linux Dev | Linux Prod |
|------|---------|-----------|------------|
| 서비스 시작 | ✅ start.ps1 | ✅ start.sh | ✅ start-prod.sh |
| 서비스 중지 | ✅ stop.ps1 | ✅ stop.sh | ✅ stop-prod.sh |
| 로그 확인 | ✅ logs.ps1 | ✅ logs.sh | ✅ (docker-compose) |
| 상태 확인 | ❌ | ✅ status.sh | ✅ status-prod.sh |
| 완전 초기화 | ✅ reset.ps1 | ✅ reset.sh | ❌ (수동) |
| 백업 | ❌ | ❌ | ✅ backup-prod.sh |
| 스토리지 마운트 | ❌ | ❌ | ✅ mount-storage.sh |

## 🎯 사용 시나리오

### 시나리오 1: 로컬 개발 (Windows)
개발자가 Windows PC에서 작업:
```powershell
cd scripts\windows
.\start.ps1
# 개발 작업...
.\logs.ps1 milvus  # 문제 발생 시
.\stop.ps1
```

### 시나리오 2: 서버 테스트 (Linux Dev)
Linux 서버에서 기능 테스트:
```bash
cd scripts/linux/dev
./start.sh
./status.sh  # 상태 확인
./logs.sh    # 로그 모니터링
./stop.sh
```

### 시나리오 3: 프로덕션 배포 (Linux Prod)
운영 서버에 배포:
```bash
# 초기 설정
cd scripts/linux
sudo ./install-dependencies.sh
./setup-permissions.sh

# 스토리지 마운트
cd production/
./mount-storage.sh

# 환경 변수 설정
cd ../../../../
echo "STORAGE_SERVER_PATH=/mnt/storage/rag-data" > .env
echo "POSTGRES_PASSWORD=secure_password" >> .env

# 서비스 시작
cd scripts/linux/production
./start-prod.sh

# 모니터링
./status-prod.sh

# 정기 백업
./backup-prod.sh
```

## 🔄 마이그레이션 경로

### 개발 → 테스트
```bash
# Windows에서 개발 완료 후
# Linux 테스트 서버로 이동
cd scripts/linux/dev
./start.sh
```

### 테스트 → 프로덕션
```bash
# 테스트 완료 후
cd scripts/linux/production
./mount-storage.sh    # 외부 스토리지 설정
./start-prod.sh       # 프로덕션 배포
```

## 💡 팁

### Windows에서 Linux 스크립트 실행 (WSL)
Windows에 WSL2가 설치되어 있다면:
```bash
wsl
cd /mnt/c/DEVELOP/Milvus_docker/scripts/linux/dev
./start.sh
```

### 원격 서버 관리
```bash
# SSH로 연결
ssh user@server-ip

# 스크립트 실행
cd /path/to/Milvus_docker/scripts/linux/production
./status-prod.sh
```

## ⚠️ 주의사항

1. **Windows와 Linux는 다른 Docker 환경**
   - Windows: Docker Desktop (VM 기반)
   - Linux: Docker Engine (네이티브)

2. **스크립트 파일 줄바꿈**
   - Windows: CRLF (`\r\n`)
   - Linux: LF (`\n`)
   - Git 설정으로 자동 변환 권장

3. **파일 권한**
   - Linux 스크립트는 실행 권한 필요
   - `setup-permissions.sh` 실행

4. **환경 변수**
   - 프로덕션: `.env` 파일 또는 export 사용
   - 개발: 기본값 사용

## 🔗 관련 파일

- `../docker-compose.yml` - 개발 환경 설정
- `../docker-compose.production.yml` - 프로덕션 환경 설정
- `../DEPLOYMENT_GUIDE.md` - 배포 가이드
- `../STORAGE_SETUP.md` - 스토리지 설정

## 📞 문제 해결

각 환경별 README의 "문제 해결" 섹션 참조:
- [Windows 문제 해결](./windows/README.md#-문제-해결)
- [Linux 문제 해결](./linux/README.md#-문제-해결)

