# Infrastructure

저비용 MVP 인프라 구성 및 배포 아키텍처를 정의합니다.

## 1. 비용 목표

**월 1만원 이하 (약 $7-8 USD)**로 운영 가능한 최소 비용 인프라 구성

### 1.1 비용 최적화 원칙

1. **무료 티어 최대 활용**: Oracle Cloud, Vercel, Cloudflare 등
2. **단일 서버 구성**: 모든 백엔드 서비스를 하나의 VM에서 운영
3. **관리형 서비스 최소화**: 직접 설치/운영으로 비용 절감
4. **경량화**: SQLite, 인메모리 큐 등 가벼운 대안 채택

---

## 2. 환경 구성

### 2.1 환경 분류 (MVP 최소화)

| 환경 | 목적 | 구성 |
|------|------|------|
| Local | 개발자 로컬 개발 | Docker Compose |
| Production | MVP 실 서비스 | 단일 VM (무료/저가) |

> **Note**: MVP 단계에서는 Staging 환경을 생략하고, Local → Production 직접 배포

### 2.2 권장 구성: Oracle Cloud Free Tier (완전 무료)

| 컴포넌트 | 구성 | 비용 |
|----------|------|------|
| Frontend | Vercel Free Tier | **무료** |
| Backend + Judge0 | Oracle Cloud ARM VM (4 OCPU, 24GB RAM) | **무료** |
| Database | SQLite (VM 내) | **무료** |
| 도메인 | Cloudflare (DNS만) 또는 무료 서브도메인 | **무료** |
| **월 총 비용** | | **₩0** |

### 2.3 대안 구성: 저가 VPS (월 ~₩7,000)

| 컴포넌트 | 구성 | 비용 (USD) |
|----------|------|------------|
| Frontend | Vercel Free Tier | 무료 |
| Backend + Judge0 | Vultr/DigitalOcean 저가 VPS (1 vCPU, 1-2GB RAM) | ~$5-6/월 |
| Database | SQLite (VM 내) | 포함 |
| **월 총 비용** | | **~$5-6 (₩7,000)** |

---

## 3. Production 아키텍처 (단일 VM)

### 3.1 구성도

```
                    ┌─────────────────┐
                    │   Cloudflare    │
                    │   (DNS/CDN)     │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
     ┌────────────────┐            ┌────────────────┐
     │     Vercel     │            │   Single VM    │
     │   (Frontend)   │            │  (Backend)     │
     │    Next.js     │            │                │
     └────────────────┘            │  ┌──────────┐  │
              │                    │  │ Spring   │  │
              │   API Calls        │  │ Boot     │  │
              └───────────────────▶│  │ :8080    │  │
                                   │  └────┬─────┘  │
                                   │       │        │
                                   │  ┌────▼─────┐  │
                                   │  │  SQLite  │  │
                                   │  │  (DB)    │  │
                                   │  └──────────┘  │
                                   │                │
                                   │  ┌──────────┐  │
                                   │  │ Judge0   │  │
                                   │  │ (Docker) │  │
                                   │  │  :2358   │  │
                                   │  └──────────┘  │
                                   └────────────────┘
```

### 3.2 단일 VM 내부 구성

```
┌─────────────────────────────────────────────────────────┐
│                    Single VM                             │
│  OS: Ubuntu 22.04 / Oracle Linux                        │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Docker Compose                      │    │
│  │                                                  │    │
│  │  ┌────────────┐  ┌────────────┐                │    │
│  │  │  Spring    │  │  Judge0    │                │    │
│  │  │   Boot     │  │  Server    │                │    │
│  │  │  (Java)    │  │  + Worker  │                │    │
│  │  │   :8080    │  │   :2358    │                │    │
│  │  └─────┬──────┘  └─────┬──────┘                │    │
│  │        │               │                        │    │
│  │        │    ┌──────────┘                       │    │
│  │        │    │                                   │    │
│  │        ▼    ▼                                   │    │
│  │  ┌────────────┐  ┌────────────┐                │    │
│  │  │  SQLite    │  │ Judge0 DB  │                │    │
│  │  │  (App DB)  │  │ (Postgres) │                │    │
│  │  └────────────┘  └────────────┘                │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Nginx (Reverse Proxy)               │    │
│  │              :80, :443 (Let's Encrypt)          │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

---

## 4. Local Development (Docker Compose)

### 4.1 구성도

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Network                        │
│  ┌─────────────┐  ┌─────────────────────────────────┐  │
│  │  judge0-db  │  │        judge0-server            │  │
│  │  (postgres) │  │        + judge0-worker          │  │
│  │    :5432    │  │           :2358                 │  │
│  └─────────────┘  └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
         │                        │
         ▼                        ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Frontend   │    │   Backend   │    │   SQLite    │
│  (host)     │    │   (host)    │    │   (file)    │
│  :3000      │    │   :8080     │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
```

### 4.2 docker-compose.yml (최소 구성)

```yaml
version: '3.8'

services:
  # Judge0 Server + Worker (단일 컨테이너)
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
      # 리소스 제한 (MVP용 최소 설정)
      - MAX_QUEUE_SIZE=10
      - CPU_TIME_LIMIT=5
      - WALL_TIME_LIMIT=10
      - MEMORY_LIMIT=256000
      - ENABLE_NETWORK=false
      # 워커 수 최소화
      - MAX_NUMBER_OF_CONCURRENT_JOBS=2
    depends_on:
      - judge0-db
      - judge0-redis
    privileged: true
    restart: unless-stopped

  # Judge0 전용 PostgreSQL (최소 리소스)
  judge0-db:
    image: postgres:15-alpine
    container_name: ct-judge0-db
    environment:
      POSTGRES_DB: judge0
      POSTGRES_USER: judge0
      POSTGRES_PASSWORD: judge0_password
    volumes:
      - judge0_db_data:/var/lib/postgresql/data
    # 메모리 제한
    deploy:
      resources:
        limits:
          memory: 256M

  # Judge0 전용 Redis (최소 리소스)
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

### 4.3 로컬 실행 명령어

```bash
# 인프라 시작
docker-compose up -d

# 백엔드 실행 (별도 터미널)
cd backend && ./gradlew bootRun

# 프론트엔드 실행 (별도 터미널)
cd frontend && npm run dev

# 상태 확인
docker-compose ps

# 종료
docker-compose down
```

---

## 5. Oracle Cloud Free Tier 설정 가이드

### 5.1 무료 리소스

| 리소스 | 스펙 | 제한 |
|--------|------|------|
| ARM VM | 4 OCPU, 24GB RAM | 항상 무료 |
| Boot Volume | 200GB | 항상 무료 |
| Outbound Data | 10TB/월 | 항상 무료 |

> **주의**: AMD VM (1 OCPU, 1GB)도 무료지만, ARM이 훨씬 강력하므로 ARM 권장

### 5.2 VM 생성 가이드

1. **Oracle Cloud 계정 생성** (신용카드 필요, 과금 안됨)
2. **Compute Instance 생성**
   - Shape: `VM.Standard.A1.Flex` (ARM)
   - OCPU: 4, Memory: 24GB
   - Image: Ubuntu 22.04
   - Boot Volume: 100GB
3. **네트워크 설정**
   - Public IP 할당
   - Security List에 포트 오픈: 80, 443, 8080

### 5.3 서버 초기 설정

```bash
# Docker 설치
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER

# Java 17 설치 (Spring Boot용)
sudo apt install -y openjdk-17-jdk

# Nginx 설치
sudo apt install -y nginx certbot python3-certbot-nginx

# 방화벽 설정
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save
```

---

## 6. 저가 VPS 대안

### 6.1 추천 VPS 제공업체

| 제공업체 | 최저 플랜 | 스펙 | 가격 |
|----------|-----------|------|------|
| Vultr | Cloud Compute | 1 vCPU, 1GB RAM, 25GB SSD | $5/월 |
| DigitalOcean | Basic Droplet | 1 vCPU, 1GB RAM, 25GB SSD | $6/월 |
| Hetzner | CX11 | 1 vCPU, 2GB RAM, 20GB SSD | €3.29/월 |
| Contabo | VPS S | 4 vCPU, 8GB RAM, 50GB SSD | €5.99/월 |

> **권장**: Hetzner 또는 Contabo (가성비 우수)

### 6.2 VPS 최소 요구사항

- CPU: 1+ vCPU (2+ 권장)
- RAM: 2GB+ (Judge0 실행을 위해)
- Storage: 20GB+
- OS: Ubuntu 22.04 LTS

---

## 7. 배포 파이프라인 (간소화)

### 7.1 CI/CD 구성

```
┌─────────┐     ┌─────────────┐     ┌─────────────┐
│  Push   │────▶│   GitHub    │────▶│   Deploy    │
│  Code   │     │   Actions   │     │             │
└─────────┘     └─────────────┘     └─────────────┘
                      │                    │
                      │              ┌─────┴─────┐
               ┌──────┴──────┐      │           │
               │   Build     │      │  Vercel   │
               │   Test      │      │  (auto)   │
               └─────────────┘      │           │
                                    │   SSH     │
                                    │  Deploy   │
                                    │  (BE)     │
                                    └───────────┘
```

### 7.2 브랜치별 배포

| Branch | 환경 | 배포 방식 |
|--------|------|-----------|
| `main` | Production | Vercel (자동) + 백엔드 (수동/GitHub Actions) |
| `feature/*` | - | PR Preview (Vercel만) |

### 7.3 백엔드 배포 스크립트

```bash
#!/bin/bash
# deploy.sh - 서버에서 실행

cd /opt/ct-system

# 최신 코드 pull
git pull origin main

# 백엔드 빌드
cd backend
./gradlew build -x test

# 서비스 재시작
sudo systemctl restart ct-backend
```

### 7.4 GitHub Actions (선택적)

```yaml
# .github/workflows/deploy.yml
name: Deploy Backend

on:
  push:
    branches: [main]
    paths:
      - 'backend/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Server
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd /opt/ct-system
            git pull origin main
            cd backend
            ./gradlew build -x test
            sudo systemctl restart ct-backend
```

---

## 8. 비용 비교표

### 8.1 구성별 월 비용

| 구성 | Frontend | Backend | DB | 총 비용 |
|------|----------|---------|-----|---------|
| **Oracle Free** | Vercel 무료 | OCI ARM 무료 | SQLite | **₩0** |
| **저가 VPS** | Vercel 무료 | Vultr $5 | SQLite | **~₩7,000** |
| **기존 AWS** | Vercel | ECS + RDS + ElastiCache | PostgreSQL | **~₩180,000** |

### 8.2 트레이드오프

| 항목 | 무료/저가 구성 | AWS 구성 |
|------|----------------|----------|
| 비용 | ₩0 ~ ₩10,000/월 | ₩150,000+/월 |
| 가용성 | 단일 장애점 | 고가용성 |
| 확장성 | 수동 (서버 교체) | 자동 스케일링 |
| 동시 처리 | Run 10, Submit 5 | Run 50, Submit 20 |
| 복구 시간 | 수 시간 | 수 분 |
| 운영 부담 | 직접 관리 | 관리형 서비스 |

> **MVP 판단**: 유저가 거의 없는 초기 단계에서는 무료/저가 구성으로 충분

---

## 9. 모니터링 (무료 도구)

### 9.1 권장 무료 모니터링

| 도구 | 용도 | 비용 |
|------|------|------|
| UptimeRobot | 서비스 가용성 모니터링 | 무료 (50개 모니터) |
| Sentry | 에러 트래킹 | 무료 (5k 이벤트/월) |
| Vercel Analytics | 프론트엔드 성능 | 무료 (제한적) |

### 9.2 서버 모니터링

```bash
# 간단한 헬스체크 스크립트
#!/bin/bash
# /opt/scripts/healthcheck.sh

# 백엔드 체크
curl -sf http://localhost:8080/actuator/health || echo "Backend DOWN"

# Judge0 체크
curl -sf http://localhost:2358/about || echo "Judge0 DOWN"
```

```bash
# Crontab 등록
*/5 * * * * /opt/scripts/healthcheck.sh >> /var/log/healthcheck.log 2>&1
```

---

## 10. 백업 전략 (MVP)

### 10.1 SQLite 백업

```bash
#!/bin/bash
# /opt/scripts/backup.sh

BACKUP_DIR=/opt/backups
DB_PATH=/opt/ct-system/data/ct_system.db
DATE=$(date +%Y%m%d_%H%M%S)

# SQLite 백업 (hot backup)
sqlite3 $DB_PATH ".backup '$BACKUP_DIR/ct_system_$DATE.db'"

# 7일 이상 된 백업 삭제
find $BACKUP_DIR -name "*.db" -mtime +7 -delete
```

```bash
# 매일 자정 백업
0 0 * * * /opt/scripts/backup.sh
```

### 10.2 복구 절차

1. **서버 장애 시**
   - 새 VM 생성
   - 동일 설정 스크립트 실행
   - 최신 백업에서 DB 복원

2. **데이터 복구**
   ```bash
   cp /opt/backups/ct_system_YYYYMMDD.db /opt/ct-system/data/ct_system.db
   sudo systemctl restart ct-backend
   ```

---

## 11. 확장 경로

MVP 성공 후 트래픽 증가 시 단계적 확장:

### Phase 1: 현재 (MVP)
- 단일 VM, SQLite, 무료/저가

### Phase 2: 초기 성장
- VPS 업그레이드 (2-4 vCPU, 4-8GB RAM)
- SQLite → PostgreSQL 마이그레이션
- 비용: 월 ₩20,000 ~ ₩50,000

### Phase 3: 본격 성장
- 클라우드 마이그레이션 (AWS/GCP)
- 로드밸런서 + 다중 인스턴스
- 관리형 DB 도입
- 비용: 월 ₩100,000+

> **원칙**: 필요할 때 확장. 미리 과투자하지 않음.
