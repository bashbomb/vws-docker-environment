#!/bin/bash

# 문제 수 체크용 변수
errors=0

# 체크 항목 (성공/실패만 카운트)
[ -d /var/log/nginx ] || errors=$((errors+1))
[ -s /var/log/nginx/access.log ] || errors=$((errors+1))
grep -q 'error' /var/log/messages || errors=$((errors+1))
[ -x /usr/local/bin/backup.sh ] || errors=$((errors+1))
crontab -l | grep -q '/usr/local/bin/backup.sh' || errors=$((errors+1))
[ -f /etc/cron.d/vws-env ] || errors=$((errors+1))

# 결과 출력
if [ "$errors" -eq 0 ]; then
  echo "✅ 실습 환경이 정상적으로 설정되었습니다. 시나리오를 진행하세요."
else
  echo "❌ 실습 환경 설정에 문제가 있습니다."
  echo "🔄 컨테이너를 재시작한 뒤, 다시 다음 명령어를 실행하세요:"
  echo "./scenario1-1.sh"
fi
