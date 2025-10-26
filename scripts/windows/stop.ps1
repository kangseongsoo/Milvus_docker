# Docker Compose 중지 스크립트 (PowerShell)

Write-Host "🛑 Stopping all services..." -ForegroundColor Yellow

# Docker Compose 중지
docker-compose stop

Write-Host "`n✅ All services stopped!" -ForegroundColor Green
Write-Host "`n💡 To remove containers:" -ForegroundColor Cyan
Write-Host "   docker-compose down"
Write-Host "`n💡 To remove containers + volumes (데이터 삭제):" -ForegroundColor Red
Write-Host "   docker-compose down -v"

