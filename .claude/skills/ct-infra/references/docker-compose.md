# Docker Compose 설정

## 로컬 개발용 docker-compose.yml

```yaml
version: '3.8'

services:
  judge0:
    image: judge0/judge0:1.13.0
    container_name: ct-judge0
    ports:
      - "2358:2358"
    environment:
      - REDIS_HOST=judge0-redis
      - REDIS_PORT=6379
      - POSTGRES_HOST=judge0-db
      - POSTGRES_DB=judge0
      - POSTGRES_USER=judge0
      - POSTGRES_PASSWORD=judge0_password
      - MAX_QUEUE_SIZE=10
      - CPU_TIME_LIMIT=5
      - WALL_TIME_LIMIT=10
      - MEMORY_LIMIT=256000
      - ENABLE_NETWORK=false
      - MAX_NUMBER_OF_CONCURRENT_JOBS=2
    depends_on:
      - judge0-db
      - judge0-redis
    privileged: true
    restart: unless-stopped

  judge0-db:
    image: postgres:15-alpine
    container_name: ct-judge0-db
    environment:
      POSTGRES_DB: judge0
      POSTGRES_USER: judge0
      POSTGRES_PASSWORD: judge0_password
    volumes:
      - judge0_db_data:/var/lib/postgresql/data
    deploy:
      resources:
        limits:
          memory: 256M

  judge0-redis:
    image: redis:7-alpine
    container_name: ct-judge0-redis
    command: redis-server --maxmemory 64mb --maxmemory-policy allkeys-lru
    deploy:
      resources:
        limits:
          memory: 64M

volumes:
  judge0_db_data:

networks:
  default:
    name: ct-network
```

## 명령어

```bash
# 시작
docker-compose up -d

# 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f judge0

# 종료
docker-compose down

# 볼륨 포함 완전 삭제
docker-compose down -v
```
