# Judge0 Security Configuration

Judge0 실행 환경의 보안 설정 가이드입니다.

## 1. 보안 개요

### 1.1 위협 모델

**잠재적 위협:**
| 위협 | 위험도 | 대응 |
|------|--------|------|
| 코드 인젝션 | 높음 | 샌드박스 격리 |
| 리소스 고갈 (DoS) | 높음 | 리소스 제한 |
| 네트워크 공격 | 높음 | 네트워크 차단 |
| 파일시스템 접근 | 중간 | 격리된 파일시스템 |
| 프로세스 탈출 | 중간 | isolate 사용 |
| 정보 유출 | 중간 | 출력 제한 |

### 1.2 방어 계층

```
┌─────────────────────────────────────────────────────┐
│              Layer 1: Application Level             │
│  - Input validation                                 │
│  - Code size limits                                 │
│  - Rate limiting                                    │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│              Layer 2: Judge0 Level                  │
│  - Resource limits (CPU, Memory, Time)              │
│  - Network blocking                                 │
│  - File size limits                                 │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│              Layer 3: isolate Level                 │
│  - cgroups resource control                         │
│  - namespace isolation                              │
│  - seccomp filtering                                │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│              Layer 4: Container Level               │
│  - Docker isolation                                 │
│  - Read-only filesystem                             │
│  - Dropped capabilities                             │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│              Layer 5: Network Level                 │
│  - Isolated subnet                                  │
│  - No internet access                               │
│  - Internal API only                                │
└─────────────────────────────────────────────────────┘
```

---

## 2. Judge0 환경변수 설정

### 2.1 리소스 제한

```yaml
# docker-compose.yml 환경변수
environment:
  # CPU 제한
  - CPU_TIME_LIMIT=5              # CPU 시간 제한 (초)
  - CPU_EXTRA_TIME=1              # 추가 허용 시간 (초)
  - MAX_CPU_TIME_LIMIT=15         # 최대 CPU 시간 (관리자용)
  - MAX_CPU_EXTRA_TIME=5          # 최대 추가 시간 (관리자용)

  # 실제 경과 시간 제한
  - WALL_TIME_LIMIT=10            # 벽시계 시간 제한 (초)
  - MAX_WALL_TIME_LIMIT=20        # 최대 벽시계 시간

  # 메모리 제한
  - MEMORY_LIMIT=512000           # 메모리 제한 (KB) = 512MB
  - MAX_MEMORY_LIMIT=1024000      # 최대 메모리 = 1GB
  - STACK_LIMIT=64000             # 스택 제한 (KB) = 64MB
  - MAX_STACK_LIMIT=128000        # 최대 스택

  # 프로세스 제한
  - MAX_PROCESSES_AND_OR_THREADS=60  # 최대 프로세스/스레드

  # 파일 제한
  - MAX_FILE_SIZE=1024            # 출력 파일 최대 크기 (KB)
  - MAX_EXTRACT_SIZE=10240        # 압축 해제 최대 크기 (KB)
```

### 2.2 네트워크 차단

```yaml
environment:
  # 네트워크 완전 차단
  - ENABLE_NETWORK=false

  # 추가 네트워크 보안 (향후 옵션)
  # - NETWORK_NAMESPACE=true
  # - BLOCK_METADATA_SERVICE=true
```

### 2.3 보안 설정

```yaml
environment:
  # 제출 관리
  - DISABLE_SUBMISSION_DESTROY=false   # 완료된 제출 삭제 허용
  - ENABLE_BATCHED_SUBMISSIONS=true    # 배치 제출 활성화
  - MAX_QUEUE_SIZE=100                 # 큐 최대 크기
  - NUMBER_OF_RUNS=1                   # 실행 횟수 (채점용)

  # 보안 관련
  - ENABLE_SUBMISSION_CACHE=false      # 캐시 비활성화 (보안)
  - ENABLE_ADDITIONAL_FILES=false      # 추가 파일 비활성화
```

### 2.4 전체 docker-compose.yml 예시

```yaml
version: '3.8'

services:
  judge0-server:
    image: judge0/judge0:1.13.0
    container_name: ct-judge0
    ports:
      - "127.0.0.1:2358:2358"  # localhost에서만 접근
    environment:
      # Redis 연결
      - REDIS_HOST=judge0-redis
      - REDIS_PORT=6379

      # PostgreSQL 연결
      - POSTGRES_HOST=judge0-db
      - POSTGRES_DB=judge0
      - POSTGRES_USER=judge0
      - POSTGRES_PASSWORD=${JUDGE0_DB_PASSWORD}

      # 리소스 제한 (MVP 기준)
      - CPU_TIME_LIMIT=5
      - CPU_EXTRA_TIME=1
      - WALL_TIME_LIMIT=10
      - MEMORY_LIMIT=524288        # 512MB
      - STACK_LIMIT=65536          # 64MB
      - MAX_PROCESSES_AND_OR_THREADS=60
      - MAX_FILE_SIZE=1024

      # 보안 설정
      - ENABLE_NETWORK=false
      - DISABLE_SUBMISSION_DESTROY=false
      - ENABLE_BATCHED_SUBMISSIONS=true
      - MAX_QUEUE_SIZE=100

    depends_on:
      - judge0-db
      - judge0-redis
    networks:
      - judge0-internal
    restart: unless-stopped
    # 보안 옵션
    read_only: false  # Judge0는 쓰기 필요
    security_opt:
      - no-new-privileges:true

  judge0-workers:
    image: judge0/judge0:1.13.0
    command: ["./scripts/workers"]
    environment:
      - REDIS_HOST=judge0-redis
      - REDIS_PORT=6379
      - POSTGRES_HOST=judge0-db
      - POSTGRES_DB=judge0
      - POSTGRES_USER=judge0
      - POSTGRES_PASSWORD=${JUDGE0_DB_PASSWORD}
    depends_on:
      - judge0-server
    deploy:
      replicas: 3
    networks:
      - judge0-internal
    # 워커는 privileged 필요 (isolate 실행)
    privileged: true
    restart: unless-stopped

  judge0-db:
    image: postgres:15-alpine
    container_name: ct-judge0-db
    environment:
      POSTGRES_DB: judge0
      POSTGRES_USER: judge0
      POSTGRES_PASSWORD: ${JUDGE0_DB_PASSWORD}
    volumes:
      - judge0_db_data:/var/lib/postgresql/data
    networks:
      - judge0-internal
    # 외부 접근 차단 (포트 미노출)

  judge0-redis:
    image: redis:7-alpine
    container_name: ct-judge0-redis
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - judge0_redis_data:/data
    networks:
      - judge0-internal
    # 외부 접근 차단 (포트 미노출)

networks:
  judge0-internal:
    internal: true  # 외부 네트워크 접근 차단

volumes:
  judge0_db_data:
  judge0_redis_data:
```

---

## 3. 애플리케이션 레벨 보안

### 3.1 입력 검증

```java
@Service
@RequiredArgsConstructor
public class ExecutionService {

    private static final int MAX_CODE_SIZE = 65536;  // 64KB
    private static final int MAX_INPUT_SIZE = 10240; // 10KB
    private static final Set<String> ALLOWED_LANGUAGES = Set.of("PYTHON", "JAVA", "CPP", "JAVASCRIPT");

    public void validateExecutionRequest(ExecutionRequest request) {
        // 언어 검증
        if (!ALLOWED_LANGUAGES.contains(request.getLanguage())) {
            throw new InvalidLanguageException("Language not supported: " + request.getLanguage());
        }

        // 코드 크기 검증
        if (request.getCode() == null || request.getCode().isEmpty()) {
            throw new ValidationException("Code cannot be empty");
        }
        if (request.getCode().getBytes(StandardCharsets.UTF_8).length > MAX_CODE_SIZE) {
            throw new CodeTooLargeException("Code size exceeds maximum limit of 64KB");
        }

        // 입력 크기 검증
        if (request.getInput() != null &&
            request.getInput().getBytes(StandardCharsets.UTF_8).length > MAX_INPUT_SIZE) {
            throw new InputTooLargeException("Input size exceeds maximum limit of 10KB");
        }

        // 위험 패턴 검사 (선택적)
        validateCodePatterns(request.getCode(), request.getLanguage());
    }

    private void validateCodePatterns(String code, String language) {
        // 위험한 시스템 호출 패턴 감지 (참고용 - 샌드박스가 1차 방어)
        List<String> dangerousPatterns = List.of(
            "Runtime.getRuntime()",
            "ProcessBuilder",
            "exec(",
            "system(",
            "subprocess",
            "__import__('os')",
            "eval(",
            "exec("
        );

        String lowerCode = code.toLowerCase();
        for (String pattern : dangerousPatterns) {
            if (lowerCode.contains(pattern.toLowerCase())) {
                log.warn("Potentially dangerous pattern detected: {}", pattern);
                // 차단하지 않고 로그만 남김 (isolate가 방어)
            }
        }
    }
}
```

### 3.2 Rate Limiting

```java
@Configuration
public class RateLimitConfig {

    @Bean
    public RateLimiter runRateLimiter() {
        return RateLimiter.of("run",
            RateLimiterConfig.custom()
                .limitRefreshPeriod(Duration.ofMinutes(1))
                .limitForPeriod(30)  // 분당 30회
                .timeoutDuration(Duration.ofSeconds(5))
                .build());
    }

    @Bean
    public RateLimiter submitRateLimiter() {
        return RateLimiter.of("submit",
            RateLimiterConfig.custom()
                .limitRefreshPeriod(Duration.ofMinutes(1))
                .limitForPeriod(10)  // 분당 10회
                .timeoutDuration(Duration.ofSeconds(5))
                .build());
    }
}

@RestController
@RequiredArgsConstructor
public class ExecutionController {

    private final RateLimiter runRateLimiter;
    private final RateLimiter submitRateLimiter;

    @PostMapping("/run")
    public ResponseEntity<?> run(@RequestBody RunRequest request,
                                 HttpServletRequest httpRequest) {
        String clientKey = getClientKey(httpRequest);

        return RateLimiter.decorateSupplier(runRateLimiter, () -> {
            // 실행 로직
            return ResponseEntity.ok(executionService.run(request));
        }).get();
    }

    private String getClientKey(HttpServletRequest request) {
        String guestToken = request.getHeader("X-Guest-Token");
        String clientIp = request.getRemoteAddr();
        return guestToken != null ? guestToken : clientIp;
    }
}
```

---

## 4. 네트워크 격리

### 4.1 Docker 네트워크 설정

```yaml
networks:
  # 외부 접근용 네트워크
  frontend:
    driver: bridge

  # 내부 서비스용 네트워크
  backend:
    driver: bridge
    internal: false

  # Judge0 전용 격리 네트워크
  judge0-internal:
    driver: bridge
    internal: true  # 인터넷 접근 불가

services:
  backend:
    networks:
      - backend
      - judge0-internal  # Judge0에 접근 가능

  judge0-server:
    networks:
      - judge0-internal  # 격리된 네트워크만

  judge0-workers:
    networks:
      - judge0-internal

  judge0-db:
    networks:
      - judge0-internal

  judge0-redis:
    networks:
      - judge0-internal
```

### 4.2 AWS VPC 설정 (프로덕션)

```
┌─────────────────────────────────────────────────────────────┐
│                          VPC                                │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Public Subnet                          │    │
│  │  ┌──────────┐  ┌──────────┐                        │    │
│  │  │   ALB    │  │   NAT    │                        │    │
│  │  └────┬─────┘  └────┬─────┘                        │    │
│  └───────┼──────────────┼─────────────────────────────┘    │
│          │              │                                   │
│  ┌───────┼──────────────┼─────────────────────────────┐    │
│  │       │   Private Subnet                           │    │
│  │       ▼              │                             │    │
│  │  ┌──────────┐        │                             │    │
│  │  │ Backend  │────────┼────────┐                    │    │
│  │  │   ECS    │        │        │                    │    │
│  │  └──────────┘        │        │                    │    │
│  └──────────────────────┼────────┼────────────────────┘    │
│                         │        │                          │
│  ┌──────────────────────┼────────┼────────────────────┐    │
│  │        Isolated Subnet (Judge0)                    │    │
│  │                      │        ▼                    │    │
│  │  Route Table:        │   ┌──────────┐              │    │
│  │  - No IGW            │   │  Judge0  │              │    │
│  │  - No NAT            │   │   EC2    │              │    │
│  │                      │   └──────────┘              │    │
│  │  NACL:               │        │                    │    │
│  │  - Deny all outbound │        │                    │    │
│  │    to 0.0.0.0/0      │   ┌────▼─────┐              │    │
│  │  - Allow internal    │   │  Judge0  │              │    │
│  │                      │   │    DB    │              │    │
│  │                      │   └──────────┘              │    │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

**Security Group 규칙:**

```
# Judge0 EC2 Security Group
Inbound:
  - Port 2358 from Backend SG only
  - No other inbound

Outbound:
  - Deny all (또는 Judge0 DB/Redis로만 허용)
```

---

## 5. 문제별 설정

### 5.1 문제별 리소스 제한

```java
@Entity
public class Problem {
    // ... 기존 필드

    @Column(nullable = false)
    private Integer timeLimit = 2000;  // ms

    @Column(nullable = false)
    private Integer memoryLimit = 512; // MB

    @Column(nullable = false)
    private Integer maxOutputSize = 1024; // KB
}

@Service
public class ExecutionService {

    public Judge0SubmissionRequest buildRequest(Problem problem, String code, String language) {
        return Judge0SubmissionRequest.builder()
                .sourceCode(wrapCode(code, language, problem))
                .languageId(getLanguageId(language))
                .cpuTimeLimit((float) problem.getTimeLimit() / 1000)  // ms -> s
                .memoryLimit(problem.getMemoryLimit() * 1024)         // MB -> KB
                .build();
    }
}
```

### 5.2 언어별 추가 제한

```java
public class LanguageConfig {

    private static final Map<String, LanguageLimits> LANGUAGE_LIMITS = Map.of(
        "PYTHON", new LanguageLimits(2.0f, 512000, 60),   // 2x 시간, 512MB
        "JAVA", new LanguageLimits(2.5f, 1024000, 100),   // 2.5x 시간, 1GB, JVM 스레드
        "CPP", new LanguageLimits(1.0f, 524288, 60),      // 기준 시간, 512MB
        "JAVASCRIPT", new LanguageLimits(2.0f, 524288, 60)
    );

    public static LanguageLimits getLimits(String language) {
        return LANGUAGE_LIMITS.getOrDefault(language, LANGUAGE_LIMITS.get("CPP"));
    }

    public record LanguageLimits(
        float timeMultiplier,
        int memoryLimitKb,
        int maxProcesses
    ) {}
}
```

---

## 6. 모니터링 및 감사

### 6.1 실행 로그

```java
@Slf4j
@Service
public class ExecutionService {

    public ExecutionResult execute(ExecutionRequest request) {
        String executionId = UUID.randomUUID().toString();

        log.info("Execution started: id={}, problem={}, language={}, codeSize={}",
            executionId,
            request.getProblemId(),
            request.getLanguage(),
            request.getCode().length()
        );

        try {
            ExecutionResult result = doExecute(request);

            log.info("Execution completed: id={}, status={}, time={}ms, memory={}KB",
                executionId,
                result.getStatus(),
                result.getExecutionTime(),
                result.getMemoryUsed()
            );

            return result;
        } catch (Exception e) {
            log.error("Execution failed: id={}, error={}", executionId, e.getMessage(), e);
            throw e;
        }
    }
}
```

### 6.2 보안 이벤트 알림

```java
@Component
@RequiredArgsConstructor
public class SecurityEventListener {

    private final SlackNotifier slackNotifier;

    @EventListener
    public void onRateLimitExceeded(RateLimitExceededEvent event) {
        if (event.getExceededCount() > 10) {
            slackNotifier.alert(String.format(
                "Rate limit exceeded: IP=%s, count=%d",
                event.getClientIp(),
                event.getExceededCount()
            ));
        }
    }

    @EventListener
    public void onSuspiciousActivity(SuspiciousActivityEvent event) {
        slackNotifier.alert(String.format(
            "Suspicious activity detected: type=%s, details=%s",
            event.getType(),
            event.getDetails()
        ));
    }
}
```

---

## 7. 보안 체크리스트

### 7.1 배포 전 체크리스트

- [ ] Judge0 네트워크 격리 확인 (`ENABLE_NETWORK=false`)
- [ ] 리소스 제한 설정 확인 (CPU, 메모리, 시간)
- [ ] Judge0 포트 외부 노출 안 함 (localhost 또는 내부 네트워크만)
- [ ] Judge0 DB 패스워드 환경변수 또는 Secrets Manager
- [ ] Rate limiting 활성화
- [ ] 입력 검증 로직 테스트
- [ ] 보안 로그 수집 설정
- [ ] 알림 설정 확인

### 7.2 정기 점검 항목

- [ ] Judge0 버전 보안 업데이트 확인
- [ ] Docker 이미지 보안 스캔
- [ ] 비정상 실행 패턴 로그 분석
- [ ] 리소스 사용량 모니터링
- [ ] 접근 로그 감사

---

## 8. 향후 보안 강화 (로드맵)

### MVP 이후 고려사항

| 단계 | 항목 | 설명 |
|------|------|------|
| Phase 1 | API Key 인증 | Judge0 API에 인증 추가 |
| Phase 2 | gVisor | 강화된 컨테이너 격리 |
| Phase 3 | Firecracker | 마이크로VM 기반 격리 |
| Phase 4 | 행위 분석 | 악성 코드 패턴 ML 탐지 |
