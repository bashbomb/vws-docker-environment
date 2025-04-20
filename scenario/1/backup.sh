#!/bin/bash
DATE=$(/bin/date +%F)

LOG_DIR="/mnt/backup/logs/${DATE}"
WEB_DIR="/mnt/backup/web_src/${DATE}"
CONFIG_DIR="/mnt/backup/config/${DATE}"

/bin/mkdir -p "${LOG_DIR}" "${WEB_DIR}" "${CONFIG_DIR}"

/bin/tar czf "${WEB_DIR}/html.tar.gz" -C /usr/share/nginx/html .
/bin/tar czf "${CONFIG_DIR}/nginx_config.tar.gz" -C /etc/nginx .

# 로그 백업
tar czf "${LOG_DIR}/nginx_logs.tar.gz" -C /var/log/nginx .
grep error /var/log/messages > "${LOG_DIR}/messages.log"
