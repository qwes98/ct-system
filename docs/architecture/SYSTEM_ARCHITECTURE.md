# System Architecture

코딩테스트 연습 플랫폼의 전체 시스템 아키텍처 문서입니다.

## 1. 시스템 개요 (저비용 MVP)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Client (Browser)                                │
│                         Next.js + shadcn/ui + Monaco                        │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │ HTTPS
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Vercel (Frontend)                               │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │ API Calls
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      Single VM (Backend + Judge0)                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    Backend API (Spring Boot)                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │   │
│  │  │  Problem    │  │    Run      │  │   Submit    │                  │   │
│  │  │  Service    │  │   Service   │  │   Service   │                  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                  │   │
│  │         │                │                │                          │   │
│  │         ▼                ▼                ▼                          │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │   │
│  │  │   SQLite    │  │   Judge0    │  │  In-Memory  │                  │   │
│  │  │   (Data)    │  │  (Execute)  │  │   Queue     │                  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.1 아키텍처 원칙 (MVP)

| 원칙 | 설명 |
|------|------|
| **단순성** | 최소한의 컴포넌트로 구성 |
| **비용 효율** | 월 1만원 이하 운영 |
| **단일 서버** | 모든 백엔드를 하나의 VM에서 실행 |
| **내장 솔루션** | Redis 대신 인메모리 큐, PostgreSQL 대신 SQLite |

---

## 2. 컴포넌트 상세

### 2.1 Frontend (Next.js)

| 항목 | 설명 |
|------|------|
| Framework | Next.js 14+ (App Router) |
| UI Library | shadcn/ui (Radix UI 기반) |
| Code Editor | Monaco Editor |
| State Management | React Context / Zustand |
| HTTP Client | Fetch API |
| Hosting | **Vercel Free Tier** |

**주요 페이지:**
- `/` - 문제 리스트
- `/problems/[id]` - 문제 풀이 페이지 (에디터 + 결과)
- `/submissions` - 제출 이력

### 2.2 Backend API (Spring Boot)

| 항목 | 설명 |
|------|------|
| Framework | Spring Boot 3.x |
| Language | Java 17+ |
| Build Tool | Gradle |
| API Style | REST API |
| Documentation | SpringDoc OpenAPI (Swagger) |

**핵심 서비스:**

```
├── ProblemService        # 문제 CRUD, 템플릿 제공
├── RunService            # 샘플 테스트 실행 (동기)
├── SubmitService         # 전체 테스트 제출 (인메모리 큐 + 비동기)
├── ExecutionService      # Judge0 연동
├── SubmissionService     # 제출 이력 관리
└── GuestSessionService   # 게스트 토큰 관리
```

### 2.3 Database (SQLite)

| 항목 | 설명 |
|------|------|
| Database | SQLite 3.x |
| ORM | Spring Data JPA + Hibernate |
| Migration | Flyway |
| Location | 파일 기반 (VM 로컬 스토리지) |

**SQLite 선택 이유 (MVP):**
- 별도 서버 불필요 (비용 절감)
- 설정 간단, 운영 부담 최소
- MVP 규모 (동시 10명 이하)에서 충분한 성능
- 필요시 PostgreSQL로 쉽게 마이그레이션 가능

### 2.4 Message Queue (In-Memory)

| 항목 | 설명 |
|------|------|
| Implementation | Java BlockingQueue 또는 Spring @Async |
| Purpose | Submit 비동기 처리 |
| Persistence | 없음 (서버 재시작 시 유실) |

**Redis 대신 인메모리 큐 선택 이유:**
- 별도 Redis 서버 불필요 (비용 절감)
- MVP 규모에서 메시지 유실 위험 허용 가능
- 단일 서버이므로 분산 큐 불필요

```java
// 간단한 인메모리 큐 구현 예시
@Service
public class SubmitQueueService {
    private final BlockingQueue<SubmitTask> queue = new LinkedBlockingQueue<>(100);
    private final ExecutorService executor = Executors.newFixedThreadPool(2);

    @PostConstruct
    public void startWorkers() {
        for (int i = 0; i < 2; i++) {
            executor.submit(this::processQueue);
        }
    }

    public void enqueue(SubmitTask task) {
        queue.offer(task);
    }

    private void processQueue() {
        while (true) {
            try {
                SubmitTask task = queue.take();
                processSubmission(task);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }
}
```

### 2.5 Execution Engine (Judge0)

| 항목 | 설명 |
|------|------|
| Deployment | Self-hosted (Docker) |
| Languages | Python, Java, C++, JavaScript |
| Isolation | Container-based (isolate) |
| Workers | **1-2개 (최소 구성)** |

**리소스 제한 (MVP 최소 설정):**
- CPU: 1 vCPU
- Memory: 256MB
- Time Limit: 5초
- Network: 완전 차단
- 동시 실행: 2개

---

## 3. 핵심 플로우

### 3.1 Run (샘플 테스트 실행)

```
┌──────┐     ┌──────────┐     ┌──────────┐     ┌─────────┐
│Client│────▶│ Backend  │────▶│  Judge0  │────▶│ Response│
└──────┘     └──────────┘     └──────────┘     └─────────┘
   │              │                 │               │
   │  POST /run   │                 │               │
   │─────────────▶│                 │               │
   │              │  Submit code    │               │
   │              │────────────────▶│               │
   │              │                 │  Execute      │
   │              │                 │  (sync)       │
   │              │  Result         │               │
   │              │◀────────────────│               │
   │  200 OK      │                 │               │
   │◀─────────────│                 │               │
```

**특징:**
- 동기 처리 (즉시 응답)
- 샘플 테스트케이스만 실행
- **동시 처리: 10 concurrent** (MVP 축소)

### 3.2 Submit (전체 테스트 제출)

```
┌──────┐     ┌──────────┐     ┌───────────┐     ┌─────────┐
│Client│────▶│ Backend  │────▶│ In-Memory │────▶│ Judge0  │
└──────┘     └──────────┘     │   Queue   │     └─────────┘
   │              │           └───────────┘          │
   │ POST /submit │                 │                │
   │─────────────▶│                 │                │
   │              │ Enqueue         │                │
   │              │────────────────▶│                │
   │ 202 Accepted │                 │                │
   │◀─────────────│                 │                │
   │              │                 │  Dequeue &    │
   │              │                 │  Execute      │
   │              │                 │──────────────▶│
   │              │                 │  Result       │
   │              │                 │◀──────────────│
   │              │ Update DB       │                │
   │              │◀────────────────│                │
   │              │                 │                │
   │ GET /submissions/{id}          │                │
   │─────────────▶│                 │                │
   │ 200 OK       │                 │                │
   │◀─────────────│                 │                │
```

**특징:**
- 비동기 처리 (인메모리 큐 기반)
- 전체 테스트케이스 실행 (샘플 + 숨김)
- 상태 머신: `queued` → `running` → `done`
- **동시 처리: 5 concurrent** (MVP 축소)

### 3.3 제출 상태 조회 (Polling)

```
Client                    Backend                   SQLite
   │                         │                          │
   │  GET /submissions/{id}  │                          │
   │────────────────────────▶│                          │
   │                         │  SELECT status           │
   │                         │─────────────────────────▶│
   │                         │  status = 'running'      │
   │                         │◀─────────────────────────│
   │  { status: "running" }  │                          │
   │◀────────────────────────│                          │
   │                         │                          │
   │  (2초 후 재요청)          │                          │
   │────────────────────────▶│                          │
   │                         │─────────────────────────▶│
   │                         │  status = 'done'         │
   │                         │◀─────────────────────────│
   │  { status: "done", ... }│                          │
   │◀────────────────────────│                          │
```

---

## 4. 동시성 & 확장성 (MVP)

### 4.1 동시 처리 목표 (MVP 축소)

| 작업 | 목표 동시성 | 처리 방식 |
|------|-------------|-----------|
| Run | **10 concurrent** | 동기 (Judge0 직접 호출) |
| Submit | **5 concurrent** | 비동기 (인메모리 큐) |

> **Note**: MVP에서는 유저가 거의 없으므로 낮은 동시성으로 충분

### 4.2 단일 서버 구성

```
┌─────────────────────────────────────────────────┐
│                  Single VM                       │
│  ┌───────────────────────────────────────────┐  │
│  │           Spring Boot Application          │  │
│  │                                            │  │
│  │  ┌─────────────┐    ┌─────────────────┐   │  │
│  │  │   API       │    │   Submit Queue  │   │  │
│  │  │  Handlers   │    │   (In-Memory)   │   │  │
│  │  │  (Tomcat)   │    │   + Workers     │   │  │
│  │  └──────┬──────┘    └────────┬────────┘   │  │
│  │         │                    │            │  │
│  │         └────────┬───────────┘            │  │
│  │                  │                        │  │
│  │                  ▼                        │  │
│  │         ┌─────────────┐                   │  │
│  │         │   SQLite    │                   │  │
│  │         │   (File)    │                   │  │
│  │         └─────────────┘                   │  │
│  └───────────────────────────────────────────┘  │
│                                                  │
│  ┌───────────────────────────────────────────┐  │
│  │              Judge0 (Docker)               │  │
│  │   - 2 Workers max                         │  │
│  │   - PostgreSQL (Judge0 전용)               │  │
│  │   - Redis (Judge0 전용)                    │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

### 4.3 향후 확장 (필요시)

```
Phase 1 (MVP)           Phase 2 (성장)           Phase 3 (확장)
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│  Single VM  │  ──▶  │  Bigger VM  │  ──▶  │  Multiple   │
│  + SQLite   │       │  + Postgres │       │  Servers    │
└─────────────┘       └─────────────┘       └─────────────┘
 동시 10/5             동시 30/15             동시 50+/20+
 월 ~₩0               월 ~₩30,000           월 ~₩100,000+
```

---

## 5. 보안 아키텍처

### 5.1 네트워크 보안 (간소화)

```
┌─────────────────────────────────────────────────────────────┐
│                       Internet                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   Cloudflare                         │    │
│  │               (DNS + DDoS 방어)                      │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
     ┌────────────────┐              ┌────────────────┐
     │     Vercel     │              │   Single VM    │
     │   (Frontend)   │              │    (Backend)   │
     │   HTTPS only   │              │  Nginx + SSL   │
     └────────────────┘              └────────────────┘
                                              │
                                     ┌────────┴────────┐
                                     │  Judge0 Docker  │
                                     │  (No outbound)  │
                                     └─────────────────┘
```

### 5.2 애플리케이션 보안

| 계층 | 보안 조치 |
|------|-----------|
| API | Rate limiting (IP 기준, 간단한 구현) |
| Input | 코드 크기 제한 (10KB), 입력값 검증 |
| Execution | Docker 컨테이너 격리, 리소스 제한, 네트워크 차단 |
| Data | 숨김 테스트케이스 비공개, 상세 로그 미노출 |

### 5.3 간단한 Rate Limiting 구현

```java
@Component
public class SimpleRateLimiter {
    private final Map<String, Deque<Long>> requestLog = new ConcurrentHashMap<>();

    public boolean isAllowed(String ip, int maxRequests, int windowSeconds) {
        long now = System.currentTimeMillis();
        long windowStart = now - (windowSeconds * 1000L);

        requestLog.computeIfAbsent(ip, k -> new ConcurrentLinkedDeque<>());
        Deque<Long> timestamps = requestLog.get(ip);

        // 오래된 기록 제거
        while (!timestamps.isEmpty() && timestamps.peekFirst() < windowStart) {
            timestamps.pollFirst();
        }

        if (timestamps.size() >= maxRequests) {
            return false;
        }

        timestamps.addLast(now);
        return true;
    }
}
```

---

## 6. 모니터링 & 로깅 (MVP)

### 6.1 간단한 로깅

```yaml
# application.yml
logging:
  level:
    root: INFO
    com.ctsystem: DEBUG
  file:
    name: /var/log/ct-system/app.log
    max-size: 10MB
    max-history: 7
```

### 6.2 핵심 메트릭 (Spring Actuator)

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: when_authorized
```

### 6.3 핵심 SLI/SLO (MVP)

| SLI | SLO | 측정 방법 |
|-----|-----|-----------|
| Submit 응답 시간 | P95 < 10초 | 제출 → done 상태까지 |
| 제출 완료율 | 90%+ | 성공 제출 / 전체 제출 |
| API 가용성 | 95%+ | UptimeRobot 모니터링 |

> **Note**: MVP에서는 99% 가용성 목표 대신 95%로 완화

---

## 7. 기술 부채 & 향후 고려사항

### MVP에서 제외 (로드맵)

| 항목 | 현재 상태 | 향후 계획 |
|------|-----------|-----------|
| WebSocket | Polling 사용 | 실시간 피드백 필요시 도입 |
| PostgreSQL | SQLite 사용 | 트래픽 증가시 마이그레이션 |
| Redis | 인메모리 큐 | 분산 환경 필요시 도입 |
| 사용자 인증 | 게스트 only | OAuth/JWT 추가 예정 |
| 자동 스케일링 | 단일 서버 | 클라우드 마이그레이션시 |
| 고가용성 | 단일 장애점 | 트래픽 증가시 구성 |

### SQLite → PostgreSQL 마이그레이션 기준

다음 조건 중 하나라도 해당되면 PostgreSQL로 마이그레이션:
1. 동시 접속자 20명 이상 빈번
2. DB 파일 크기 1GB 초과
3. 복잡한 쿼리 성능 이슈 발생
4. 다중 서버 구성 필요
