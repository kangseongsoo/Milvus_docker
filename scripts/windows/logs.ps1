# Docker Compose 로그 확인 스크립트 (PowerShell)

param(
    [string]$Service = ""
)

if ($Service -eq "") {
    Write-Host "📋 Showing logs for all services..." -ForegroundColor Cyan
    docker-compose logs -f
} else {
    Write-Host "📋 Showing logs for $Service..." -ForegroundColor Cyan
    docker-compose logs -f $Service
}

# 사용 예시:
# .\logs.ps1              # 전체 로그
# .\logs.ps1 milvus       # Milvus 로그만
# .\logs.ps1 postgres     # PostgreSQL 로그만

