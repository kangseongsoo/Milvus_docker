#!/bin/bash

# Docker Compose 중지 스크립트 (프로덕션 환경)

echo "🛑 Stopping production services..."

# 프로젝트 루트로 이동
cd ../../../
docker-compose -f docker-compose.production.yml stop

echo ""
echo "✅ All production services stopped!"
echo ""
echo "💡 서비스 관리 명령어:"
echo "   컨테이너 제거:              docker-compose -f docker-compose.production.yml down"
echo "   컨테이너 + 볼륨 제거:       docker-compose -f docker-compose.production.yml down -v"
echo "   서비스 재시작:              ./start-prod.sh"
echo ""
echo "⚠️  참고: 데이터는 외부 스토리지($STORAGE_SERVER_PATH)에 안전하게 보관됩니다."

