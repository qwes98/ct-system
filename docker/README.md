# Docker Development Environment

로컬 개발을 위한 Docker Compose 설정입니다.

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+

## Quick Start

1. 환경 변수 파일 생성:
   ```bash
   cd docker
   cp .env.example .env
   ```

2. 서비스 시작:
   ```bash
   docker-compose up -d
   ```

3. 상태 확인:
   ```bash
   docker-compose ps
   ```

4. Judge0 동작 확인:
   ```bash
   curl http://localhost:2358/about
   ```

## Services

| Service | Port | Description |
|---------|------|-------------|
| judge0 | 2358 | Code execution API |
| judge0-db | (internal) | PostgreSQL for Judge0 |
| judge0-redis | (internal) | Redis for Judge0 queue |

## Commands

```bash
# 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f judge0

# 종료
docker-compose down

# 볼륨 포함 완전 삭제
docker-compose down -v

# 재시작
docker-compose restart
```

## Security Notes

**IMPORTANT:** Before deploying to any non-local environment:

1. Generate a strong password for `JUDGE0_DB_PASSWORD` in `.env`
2. Consider firewall rules to restrict Judge0 port (2358) access
3. The Judge0 container runs in privileged mode - ensure host security
4. Never commit `.env` file to version control

## Troubleshooting

### Judge0가 시작되지 않는 경우

1. 로그 확인:
   ```bash
   docker-compose logs judge0
   ```

2. DB/Redis 상태 확인:
   ```bash
   docker-compose ps
   ```

3. 컨테이너 재시작:
   ```bash
   docker-compose restart judge0
   ```

### 포트 충돌

`.env` 파일에서 `JUDGE0_PORT` 값을 변경하세요.
