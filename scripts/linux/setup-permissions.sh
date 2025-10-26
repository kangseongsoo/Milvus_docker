#!/bin/bash

# 스크립트 파일에 실행 권한 부여

echo "🔧 Setting execute permissions for shell scripts..."
echo ""

# 개발 환경 스크립트
echo "📁 Dev scripts..."
chmod +x dev/start.sh
chmod +x dev/stop.sh
chmod +x dev/reset.sh
chmod +x dev/logs.sh
chmod +x dev/status.sh

# 프로덕션 환경 스크립트
echo "📁 Production scripts..."
chmod +x production/start-prod.sh
chmod +x production/stop-prod.sh
chmod +x production/status-prod.sh
chmod +x production/backup-prod.sh
chmod +x production/mount-storage.sh

# 공통 스크립트
echo "📁 Common scripts..."
chmod +x install-dependencies.sh
chmod +x setup-permissions.sh

echo ""
echo "✅ All scripts are now executable!"
echo ""
echo "📚 Usage Guide:"
echo ""
echo "🔷 Development Environment (dev/):"
echo "   cd dev/"
echo "   ./start.sh          - Start services"
echo "   ./stop.sh           - Stop services"
echo "   ./reset.sh          - Complete reset (delete all data)"
echo "   ./logs.sh [service] - View logs"
echo "   ./status.sh         - Check service status"
echo ""
echo "🔶 Production Environment (production/):"
echo "   cd production/"
echo "   ./mount-storage.sh  - Mount external storage (first time)"
echo "   ./start-prod.sh     - Start production services"
echo "   ./stop-prod.sh      - Stop production services"
echo "   ./status-prod.sh    - Check production status"
echo "   ./backup-prod.sh    - Backup data"
echo ""
echo "📖 Detailed guides:"
echo "   - Read README.md in this directory"
echo "   - Read README.md in windows/ directory (for Windows)"
