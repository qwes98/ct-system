# 모니터링 및 백업

## 무료 모니터링 도구

| 도구 | 용도 | 무료 한도 |
|------|------|-----------|
| UptimeRobot | 가용성 모니터링 | 50개 모니터 |
| Sentry | 에러 트래킹 | 5k 이벤트/월 |
| Vercel Analytics | 프론트엔드 성능 | 기본 무료 |

## 헬스체크 스크립트

```bash
#!/bin/bash
# /opt/scripts/healthcheck.sh

curl -sf http://localhost:8080/actuator/health || echo "Backend DOWN"
curl -sf http://localhost:2358/about || echo "Judge0 DOWN"
df -h / | awk 'NR==2 {if ($5+0 > 80) print "Disk usage: "$5}'
```

```bash
# Crontab 등록
*/5 * * * * /opt/scripts/healthcheck.sh >> /var/log/healthcheck.log 2>&1
```

## SQLite 백업

```bash
#!/bin/bash
# /opt/scripts/backup.sh

BACKUP_DIR=/opt/backups
DB_PATH=/opt/ct-system/data/ct_system.db
DATE=$(date +%Y%m%d_%H%M%S)

sqlite3 $DB_PATH ".backup '$BACKUP_DIR/ct_system_$DATE.db'"
find $BACKUP_DIR -name "*.db" -mtime +7 -delete

echo "Backup completed: ct_system_$DATE.db"
```

```bash
# 매일 자정 백업
0 0 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1
```

## 복구 절차

```bash
# 최신 백업으로 복구
cp /opt/backups/ct_system_YYYYMMDD.db /opt/ct-system/data/ct_system.db
sudo systemctl restart ct-backend
```
