# 🐧 Linux 빠른 시작 가이드

## 1️⃣ Docker 설치 (Ubuntu/Debian)

```bash
# Docker 의존성 설치
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Docker GPG 키 추가
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker 저장소 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 설치
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 로그아웃 후 재로그인 필요!
```

### CentOS/RHEL

```bash
# Docker 설치
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER
```

## 2️⃣ 스크립트 실행 권한 설정

```bash
# 01.Docker_compose 폴더로 이동
cd 01.Docker_compose

# 실행 권한 부여
chmod +x *.sh

# 또는 setup 스크립트 실행
./setup-permissions.sh
```

## 3️⃣ Docker Compose 실행

```bash
# 방법 1: 스크립트 사용 (권장)
./start.sh

# 방법 2: 직접 실행
docker-compose up -d

# 로그 확인
./logs.sh

# 상태 확인
./status.sh
```

## 4️⃣ 서비스 접속

**Attu (Milvus UI):**
```
http://localhost:3000

연결 설정:
- Milvus Address: localhost:19530
```

**PostgreSQL:**
```bash
# 컨테이너 내부 접속
docker-compose exec postgres psql -U postgres -d rag_db_chatty

# 외부에서 접속
psql -h localhost -p 5432 -U postgres -d rag_db_chatty
```

**MinIO Console:**
```
http://localhost:9001

로그인:
- Username: minioadmin
- Password: minioadmin
```

## 5️⃣ FastAPI 서버 실행

```bash
# 프로젝트 루트로 이동
cd ..

# Python 가상환경 활성화
source venv/bin/activate

# 패키지 설치 (최초 1회)
pip install -r requirements.txt

# FastAPI 서버 실행
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 백그라운드 실행
nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 > api.log 2>&1 &
```

## 6️⃣ 서비스 관리

```bash
# 중지
./stop.sh

# 재시작
docker-compose restart

# 특정 서비스만 재시작
docker-compose restart milvus

# 완전 초기화 (데이터 삭제)
./reset.sh
```

## 7️⃣ 문제 해결

### Docker 권한 오류
```bash
# docker 그룹 추가 후 재로그인
sudo usermod -aG docker $USER
exit  # 로그아웃
# 다시 로그인
```

### 포트 충돌
```bash
# 사용 중인 포트 확인
sudo netstat -tulpn | grep -E '19530|5432|3000|9000|9001'

# 또는
sudo lsof -i :19530
sudo lsof -i :5432
```

### 메모리 부족
```bash
# 사용 가능한 메모리 확인
free -h

# Docker 메모리 제한 설정
# /etc/docker/daemon.json
{
  "default-ulimits": {
    "memlock": {
      "Hard": -1,
      "Name": "memlock",
      "Soft": -1
    }
  }
}

sudo systemctl restart docker
```

### 로그 확인
```bash
# 전체 로그
./logs.sh

# Milvus 로그만
./logs.sh milvus

# PostgreSQL 로그만
./logs.sh postgres

# 최근 100줄만
docker-compose logs --tail=100 milvus
```

## 8️⃣ 시스템 요구사항

### 최소 사양
- CPU: 4코어
- RAM: 8GB
- Disk: 50GB SSD

### 권장 사양
- CPU: 16코어
- RAM: 32GB
- Disk: 500GB NVMe SSD

### 최적 사양 (프로덕션)
- CPU: 32코어 이상
- RAM: 128GB 이상
- Disk: 2TB NVMe SSD RAID

## 9️⃣ systemd 서비스 등록 (자동 시작)

```bash
# systemd 서비스 파일 생성
sudo nano /etc/systemd/system/milvus-rag.service
```

```ini
[Unit]
Description=Milvus RAG Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/path/to/01.Docker_compose
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

```bash
# 서비스 활성화
sudo systemctl daemon-reload
sudo systemctl enable milvus-rag.service
sudo systemctl start milvus-rag.service

# 상태 확인
sudo systemctl status milvus-rag.service
```

## 🚀 완료!

이제 리눅스에서 Docker Compose를 사용할 준비가 완료되었습니다! 🎉

