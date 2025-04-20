#!/bin/bash

# 1. 로그 디렉토리 생성
mkdir -p /var/log/nginx
mount /mnt
mkdir -p /mnt/backup/logs

# 2. 샘플 로그 삽입
cat sample_logs/access.log >> /var/log/nginx/access.log
cat sample_logs/messages >> /var/log/messages
cat sample_logs/cron >> /var/log/cron

# 3. 백업 스크립트 배치
cp backup.sh /usr/local/bin/backup.sh
chmod +x /usr/local/bin/backup.sh

# 4. PATH 제한 (숨김 설정)
cp vws-env /etc/cron.d/vws-env
chmod 644 /etc/cron.d/vws-env

# 5. crontab 등록 (자정 실행)
( crontab -l 2>/dev/null; echo '0 0 * * * /usr/local/bin/backup.sh >> /tmp/cron.log 2>&1' ) | crontab -
