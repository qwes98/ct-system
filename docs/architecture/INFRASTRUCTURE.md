# Infrastructure

인프라 구성 및 배포 아키텍처를 정의합니다.

## 1. 환경 구성

### 1.1 환경 분류

| 환경 | 목적 | 구성 |
|------|------|------|
| Local | 개발자 로컬 개발 | Docker Compose |
| Development | 통합 테스트, 기능 검증 | 단일 서버 또는 최소 클라우드 |
| Staging | 프로덕션 미러링, QA | 프로덕션과 동일 구조 (축소) |
| Production | 실 서비스 | 고가용성 구성 |

### 1.2 환경별 리소스 스펙

| 컴포넌트 | Local | Development | Staging | Production |
|----------|-------|-------------|---------|------------|
| Frontend | localhost:3000 | 1 instance | 1 instance | 2+ instances |
| Backend API | localhost:8080 | 1 instance | 1 instance | 2+ instances |
| Worker | 1 process | 1 process | 2 processes | 3+ processes |
| PostgreSQL | Docker | t3.micro | t3.small | t3.medium+ |
| Redis | Docker | t3.micro | t3.small | t3.small+ |
| Judge0 | Docker | 1 instance | 1 instance | 2+ instances |

---

## 2. Local Development (Docker Compose)

### 2.1 구성도

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Network                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  postgres   │  │    redis    │  │   judge0    │     │
│  │   :5432     │  │    :6379    │  │   :2358     │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │              judge0-workers (3)                  │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
         │                │                │
         ▼                ▼                ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Frontend   │    │   Backend   │    │   Worker    │
│  (host)     │    │   (host)    │    │   (host)    │
│  :3000      │    │   :8080     │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
```

### 2.2 docker-compose.yml

```yaml
version: '3.8'

services:
  # PostgreSQL
  postgres:
    image: postgres:15-alpine
    container_name: ct-postgres
    environment:
      POSTGRES_DB: ct_system
      POSTGRES_USER: ct_user
      POSTGRES_PASSWORD: ct_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ct_user -d ct_system"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis
  redis:
    image: redis:7-alpine
    container_name: ct-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Judge0 Server
  judge0-server:
    image: judge0/judge0:1.13.0
    container_name: ct-judge0
    ports:
      - "2358:2358"
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - POSTGRES_HOST=judge0-db
      - POSTGRES_DB=judge0
      - POSTGRES_USER=judge0
      - POSTGRES_PASSWORD=judge0_password
      - DISABLE_SUBMISSION_DESTROY=false
      - ENABLE_BATCHED_SUBMISSIONS=true
      - MAX_QUEUE_SIZE=100
      - CPU_TIME_LIMIT=5
      - CPU_EXTRA_TIME=1
      - WALL_TIME_LIMIT=10
      - MEMORY_LIMIT=512000
      - MAX_FILE_SIZE=1024
      - ENABLE_NETWORK=false
    depends_on:
      - judge0-db
      - judge0-redis
    restart: unless-stopped

  # Judge0 Workers
  judge0-workers:
    image: judge0/judge0:1.13.0
    command: ["./scripts/workers"]
    environment:
      - REDIS_HOST=judge0-redis
      - REDIS_PORT=6379
      - POSTGRES_HOST=judge0-db
      - POSTGRES_DB=judge0
      - POSTGRES_USER=judge0
      - POSTGRES_PASSWORD=judge0_password
    depends_on:
      - judge0-server
    deploy:
      replicas: 3
    restart: unless-stopped

  # Judge0 전용 PostgreSQL
  judge0-db:
    image: postgres:15-alpine
    container_name: ct-judge0-db
    environment:
      POSTGRES_DB: judge0
      POSTGRES_USER: judge0
      POSTGRES_PASSWORD: judge0_password
    volumes:
      - judge0_db_data:/var/lib/postgresql/data

  # Judge0 전용 Redis
  judge0-redis:
    image: redis:7-alpine
    container_name: ct-judge0-redis
    volumes:
      - judge0_redis_data:/data
    command: redis-server --appendonly yes

volumes:
  postgres_data:
  redis_data:
  judge0_db_data:
  judge0_redis_data:

networks:
  default:
    name: ct-network
```

### 2.3 로컬 실행 명령어

```bash
# 인프라 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f judge0-server

# 상태 확인
docker-compose ps

# 종료
docker-compose down

# 볼륨 포함 완전 삭제
docker-compose down -v
```

---

## 3. Cloud Infrastructure (AWS 기준)

### 3.1 Production 아키텍처

```
                        ┌─────────────────┐
                        │   CloudFront    │
                        │     (CDN)       │
                        └────────┬────────┘
                                 │
                        ┌────────▼────────┐
                        │  Route 53 (DNS) │
                        └────────┬────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
              ▼                  ▼                  ▼
     ┌────────────────┐ ┌────────────────┐ ┌────────────────┐
     │    Vercel      │ │      ALB       │ │      ALB       │
     │  (Frontend)    │ │   (Backend)    │ │   (Judge0)     │
     └────────────────┘ └───────┬────────┘ └───────┬────────┘
                                │                  │
                    ┌───────────┴───────────┐      │
                    │                       │      │
              ┌─────▼─────┐          ┌──────▼─────┐│
              │   ECS     │          │    ECS     ││
              │  Backend  │          │   Worker   ││
              │ (Fargate) │          │ (Fargate)  ││
              └─────┬─────┘          └──────┬─────┘│
                    │                       │      │
         ┌──────────┴───────────────────────┘      │
         │                                         │
         │  ┌─────────────────────────────────┐    │
         │  │        Private Subnet           │    │
         │  │  ┌─────────┐    ┌─────────┐    │    │
         └──┼─▶│   RDS   │    │ Elasti- │◀───┼────┘
            │  │PostgreSQL│    │  Cache  │    │
            │  └─────────┘    │ (Redis) │    │
            │                 └─────────┘    │
            │                                │
            │  ┌─────────────────────────┐   │
            │  │   EC2 (Judge0 Host)     │   │
            │  │  - isolate enabled      │   │
            │  │  - Docker privileged    │   │
            │  └─────────────────────────┘   │
            └─────────────────────────────────┘
```

### 3.2 AWS 서비스 구성

| 컴포넌트 | AWS 서비스 | 이유 |
|----------|------------|------|
| Frontend Hosting | Vercel | Next.js 최적화, 글로벌 CDN |
| Backend API | ECS Fargate | 컨테이너 기반, 서버리스 |
| Worker | ECS Fargate | 스케일링 용이 |
| Database | RDS PostgreSQL | 관리형, 자동 백업 |
| Cache/Queue | ElastiCache Redis | 관리형, 클러스터 지원 |
| Judge0 | EC2 | privileged 컨테이너 필요 |
| CDN | CloudFront | 정적 자산 캐싱 |
| DNS | Route 53 | AWS 네이티브 통합 |
| Secrets | Secrets Manager | 보안 자격 증명 관리 |
| Monitoring | CloudWatch | 통합 모니터링 |

### 3.3 Judge0 특수 요구사항

Judge0는 `isolate` 기반 샌드박싱을 위해 특수 권한이 필요합니다.

```yaml
# EC2에서 Docker로 Judge0 실행시 필요한 설정
docker run \
  --privileged \
  --cap-add=SYS_ADMIN \
  --security-opt seccomp=unconfined \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  judge0/judge0:1.13.0
```

**EC2 인스턴스 요구사항:**
- Instance Type: t3.medium 이상
- AMI: Amazon Linux 2023
- Docker 설치 및 privileged 모드 허용
- cgroup v1 또는 v2 지원

---

## 4. 네트워크 구성

### 4.1 VPC 설계

```
VPC: 10.0.0.0/16
│
├── Public Subnets (ALB, NAT Gateway)
│   ├── 10.0.1.0/24 (AZ-a)
│   └── 10.0.2.0/24 (AZ-b)
│
├── Private Subnets (ECS, RDS, ElastiCache)
│   ├── 10.0.10.0/24 (AZ-a)
│   └── 10.0.20.0/24 (AZ-b)
│
└── Isolated Subnets (Judge0)
    ├── 10.0.100.0/24 (AZ-a)
    └── 10.0.200.0/24 (AZ-b)
```

### 4.2 Security Groups

| Security Group | Inbound | Outbound |
|----------------|---------|----------|
| ALB-SG | 80, 443 from 0.0.0.0/0 | All to Backend-SG |
| Backend-SG | 8080 from ALB-SG | All to RDS-SG, Redis-SG, Judge0-SG |
| Worker-SG | None | All to RDS-SG, Redis-SG, Judge0-SG |
| RDS-SG | 5432 from Backend-SG, Worker-SG | None |
| Redis-SG | 6379 from Backend-SG, Worker-SG | None |
| Judge0-SG | 2358 from Backend-SG, Worker-SG | None (외부 차단) |

### 4.3 Judge0 네트워크 격리

```
┌─────────────────────────────────────────┐
│           Isolated Subnet               │
│  ┌─────────────────────────────────┐   │
│  │         Judge0 EC2              │   │
│  │  ┌───────────────────────────┐  │   │
│  │  │   Docker Container        │  │   │
│  │  │  ┌─────────────────────┐  │  │   │
│  │  │  │  isolate sandbox    │  │  │   │
│  │  │  │  (No network)       │  │  │   │
│  │  │  └─────────────────────┘  │  │   │
│  │  └───────────────────────────┘  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Route Table: No Internet Gateway       │
│  NACL: Block all outbound to Internet   │
└─────────────────────────────────────────┘
```

---

## 5. 배포 파이프라인

### 5.1 CI/CD 구성

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  Push   │────▶│ GitHub  │────▶│  Build  │────▶│ Deploy  │
│  Code   │     │ Actions │     │  Test   │     │         │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
                     │               │               │
                     │               │               │
              ┌──────┴──────┐ ┌─────┴─────┐  ┌─────┴─────┐
              │   Lint      │ │Unit Tests │  │  Vercel   │
              │   Type Check│ │Integration│  │  (FE)     │
              └─────────────┘ └───────────┘  │           │
                                             │  ECS      │
                                             │  (BE)     │
                                             └───────────┘
```

### 5.2 브랜치별 배포 전략

| Branch | 환경 | 자동 배포 |
|--------|------|-----------|
| `feature/*` | - | PR Preview (Vercel) |
| `develop` | Development | Yes |
| `release/*` | Staging | Yes |
| `main` | Production | Manual Approval |

### 5.3 GitHub Actions Workflow 예시

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Backend Tests
        run: |
          cd backend
          ./gradlew test

      - name: Frontend Tests
        run: |
          cd frontend
          npm ci
          npm run test
          npm run lint

  deploy-backend:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-2

      - name: Build and Push to ECR
        run: |
          aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY
          docker build -t ct-backend ./backend
          docker tag ct-backend:latest $ECR_REGISTRY/ct-backend:${{ github.sha }}
          docker push $ECR_REGISTRY/ct-backend:${{ github.sha }}

      - name: Deploy to ECS
        run: |
          aws ecs update-service --cluster ct-cluster --service ct-backend --force-new-deployment
```

---

## 6. 비용 추정 (MVP)

### 6.1 AWS 월 예상 비용 (ap-northeast-2)

| 서비스 | 스펙 | 월 비용 (USD) |
|--------|------|---------------|
| RDS PostgreSQL | db.t3.micro | ~$15 |
| ElastiCache Redis | cache.t3.micro | ~$12 |
| ECS Fargate (Backend) | 0.5 vCPU, 1GB x 2 | ~$30 |
| ECS Fargate (Worker) | 0.5 vCPU, 1GB x 2 | ~$30 |
| EC2 (Judge0) | t3.medium x 1 | ~$30 |
| ALB | 1 ALB | ~$20 |
| Data Transfer | ~10GB | ~$1 |
| **합계** | | **~$140/월** |

### 6.2 비용 최적화 방안

1. **Spot Instance**: Judge0 EC2에 Spot 사용 (50-70% 절감)
2. **Reserved Instance**: 안정화 후 1년 예약 (30-40% 절감)
3. **Auto Scaling**: 사용량 기반 스케일링으로 비피크 시간 비용 절감
4. **Vercel Free Tier**: 프론트엔드는 Vercel Free/Pro로 비용 절감

---

## 7. 모니터링 & 알림

### 7.1 CloudWatch 대시보드

**핵심 메트릭:**
- API Response Time (P50, P95, P99)
- Error Rate (4xx, 5xx)
- ECS CPU/Memory Utilization
- RDS Connections / CPU
- Redis Memory / Connections
- Judge0 Queue Depth

### 7.2 알림 설정

| 메트릭 | 임계값 | 알림 채널 |
|--------|--------|-----------|
| API P95 Latency | > 3초 | Slack |
| Error Rate | > 5% | Slack + PagerDuty |
| ECS CPU | > 80% | Slack |
| RDS Storage | > 80% | Slack |
| Judge0 Queue Depth | > 50 | Slack |

---

## 8. 재해 복구

### 8.1 백업 전략

| 대상 | 주기 | 보관 기간 |
|------|------|-----------|
| RDS Snapshot | Daily | 7일 |
| RDS Point-in-time | 연속 | 7일 |
| Redis Snapshot | Daily | 3일 |

### 8.2 RTO/RPO 목표 (MVP)

| 메트릭 | 목표 |
|--------|------|
| RTO (Recovery Time Objective) | < 1시간 |
| RPO (Recovery Point Objective) | < 1시간 |

**복구 절차:**
1. RDS: 최신 스냅샷에서 복원
2. ECS: 새 태스크 자동 재시작
3. Judge0: EC2 AMI에서 복원 또는 새 인스턴스 시작
