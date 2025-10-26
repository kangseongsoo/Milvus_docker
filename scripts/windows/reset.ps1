# Docker Compose 완전 초기화 스크립트 (PowerShell)

Write-Host "⚠️  WARNING: This will DELETE ALL DATA!" -ForegroundColor Red
$confirmation = Read-Host "Are you sure? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "❌ Cancelled" -ForegroundColor Yellow
    exit
}

Write-Host "`n🗑️  Removing all containers and volumes..." -ForegroundColor Yellow

# Docker Compose 완전 삭제
docker-compose down -v

# 볼륨 폴더 삭제
if (Test-Path "volumes") {
    Remove-Item -Recurse -Force "volumes"
    Write-Host "✅ Volumes directory deleted" -ForegroundColor Green
}

Write-Host "`n✅ Complete reset finished!" -ForegroundColor Green
Write-Host "`n💡 To start fresh:" -ForegroundColor Cyan
Write-Host "   docker-compose up -d"

