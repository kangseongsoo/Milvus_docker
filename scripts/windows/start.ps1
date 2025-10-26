# Docker Compose 실행 스크립트 (PowerShell)

Write-Host "🐳 Starting Milvus + PostgreSQL + Attu..." -ForegroundColor Green

# Docker Compose 실행
docker-compose up -d

# 서비스 시작 대기
Write-Host "`n⏳ Waiting for services to be healthy..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 서비스 상태 확인
Write-Host "`n📊 Service Status:" -ForegroundColor Cyan
docker-compose ps

Write-Host "`n✅ Services Started!" -ForegroundColor Green
Write-Host "`n📍 Access URLs:" -ForegroundColor Cyan
Write-Host "   - Milvus gRPC:        localhost:19530"
Write-Host "   - Attu (Milvus UI):   http://localhost:3000"
Write-Host "   - PostgreSQL:         localhost:5432"
Write-Host "   - MinIO Console:      http://localhost:9001"
Write-Host "`n💡 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Open Attu:         http://localhost:3000"
Write-Host "   2. Connect to Milvus: localhost:19530"
Write-Host "   3. Start FastAPI:     cd .. && uvicorn app.main:app --reload"

