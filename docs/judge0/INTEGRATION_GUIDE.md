# Judge0 Integration Guide

Judge0 코드 실행 엔진 연동 가이드입니다.

## 1. Judge0 개요

### 1.1 Judge0란?

Judge0는 오픈소스 온라인 코드 실행 시스템입니다. 컨테이너 기반 샌드박싱으로 안전하게 코드를 실행합니다.

**핵심 특징:**
- 60+ 프로그래밍 언어 지원
- `isolate` 기반 샌드박싱
- REST API 제공
- 비동기 실행 지원
- 리소스 제한 (CPU, 메모리, 시간)

### 1.2 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                      Judge0 System                          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  Judge0     │    │   Redis     │    │ PostgreSQL  │     │
│  │   Server    │───▶│   (Queue)   │    │   (Data)    │     │
│  └──────┬──────┘    └──────┬──────┘    └─────────────┘     │
│         │                  │                                │
│         │                  ▼                                │
│         │           ┌─────────────┐                        │
│         │           │   Workers   │                        │
│         │           │  (isolate)  │                        │
│         │           └─────────────┘                        │
│         │                  │                                │
│         ▼                  ▼                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Sandbox (isolate)                       │   │
│  │  - No network access                                 │   │
│  │  - Limited CPU/Memory                                │   │
│  │  - Temporary filesystem                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. API 연동

### 2.1 기본 엔드포인트

| 엔드포인트 | 메서드 | 설명 |
|------------|--------|------|
| `/submissions` | POST | 코드 실행 요청 |
| `/submissions/{token}` | GET | 실행 결과 조회 |
| `/submissions/batch` | POST | 배치 실행 요청 |
| `/languages` | GET | 지원 언어 목록 |
| `/about` | GET | 시스템 정보 |
| `/statuses` | GET | 상태 코드 목록 |

### 2.2 코드 실행 요청

**POST /submissions**

```bash
curl -X POST http://localhost:2358/submissions \
  -H "Content-Type: application/json" \
  -d '{
    "source_code": "print(sum([int(x) for x in input().split()]))",
    "language_id": 71,
    "stdin": "1 2 3 4 5",
    "expected_output": "15\n"
  }'
```

**Request Body:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| source_code | string | Y | 실행할 소스 코드 (Base64 또는 plain text) |
| language_id | integer | Y | 언어 ID |
| stdin | string | N | 표준 입력 |
| expected_output | string | N | 기대 출력 (비교용) |
| cpu_time_limit | float | N | CPU 시간 제한 (초) |
| cpu_extra_time | float | N | 추가 시간 허용 (초) |
| wall_time_limit | float | N | 실제 경과 시간 제한 (초) |
| memory_limit | integer | N | 메모리 제한 (KB) |
| stack_limit | integer | N | 스택 제한 (KB) |
| max_file_size | integer | N | 최대 파일 크기 (KB) |
| callback_url | string | N | 완료 시 콜백 URL |

**Response (201 Created):**

```json
{
  "token": "d85cd024-1548-4165-96c7-7bc88673f194"
}
```

### 2.3 결과 조회

**GET /submissions/{token}**

```bash
curl http://localhost:2358/submissions/d85cd024-1548-4165-96c7-7bc88673f194
```

**Response:**

```json
{
  "token": "d85cd024-1548-4165-96c7-7bc88673f194",
  "stdout": "15\n",
  "stderr": null,
  "compile_output": null,
  "message": null,
  "exit_code": 0,
  "exit_signal": null,
  "status": {
    "id": 3,
    "description": "Accepted"
  },
  "created_at": "2024-01-15T10:30:00.000Z",
  "finished_at": "2024-01-15T10:30:01.234Z",
  "time": "0.015",
  "wall_time": "0.035",
  "memory": 3456
}
```

### 2.4 필드 선택 (fields 파라미터)

특정 필드만 조회하여 응답 크기 최적화:

```bash
curl "http://localhost:2358/submissions/{token}?fields=stdout,stderr,status,time,memory"
```

### 2.5 동기 실행 (wait=true)

결과가 나올 때까지 대기:

```bash
curl -X POST "http://localhost:2358/submissions?wait=true" \
  -H "Content-Type: application/json" \
  -d '{
    "source_code": "print(\"Hello\")",
    "language_id": 71
  }'
```

---

## 3. 언어 설정

### 3.1 지원 언어 및 ID

| Language ID | 언어 | 버전 |
|-------------|------|------|
| 71 | Python | 3.8.1 |
| 62 | Java | OpenJDK 13.0.1 |
| 54 | C++ | GCC 9.2.0 |
| 63 | JavaScript | Node.js 12.14.0 |

### 3.2 언어별 템플릿 래퍼

각 언어에 맞는 입출력 래퍼 코드가 필요합니다.

**Python 래퍼:**

```python
import json
import sys

# 사용자 코드 영역
{user_code}

# 입력 파싱 및 함수 호출
if __name__ == "__main__":
    input_data = json.loads(sys.stdin.read())
    solution = Solution()
    result = solution.{function_name}(**input_data)
    print(json.dumps(result))
```

**Java 래퍼:**

```java
import java.util.*;
import com.google.gson.*;

// 사용자 코드 영역
{user_code}

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        StringBuilder sb = new StringBuilder();
        while (scanner.hasNextLine()) {
            sb.append(scanner.nextLine());
        }

        Gson gson = new Gson();
        Map<String, Object> input = gson.fromJson(sb.toString(), Map.class);

        Solution solution = new Solution();
        Object result = solution.{function_name}(/* parsed args */);

        System.out.println(gson.toJson(result));
    }
}
```

**C++ 래퍼:**

```cpp
#include <iostream>
#include <string>
#include "json.hpp"  // nlohmann/json

using json = nlohmann::json;

// 사용자 코드 영역
{user_code}

int main() {
    std::string input;
    std::getline(std::cin, input);

    json j = json::parse(input);
    Solution solution;
    auto result = solution.{function_name}(/* parsed args */);

    std::cout << json(result).dump() << std::endl;
    return 0;
}
```

**JavaScript 래퍼:**

```javascript
const readline = require('readline');

// 사용자 코드 영역
{user_code}

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

let inputData = '';
rl.on('line', (line) => {
    inputData += line;
});

rl.on('close', () => {
    const input = JSON.parse(inputData);
    const solution = new Solution();
    const result = solution.{function_name}(...Object.values(input));
    console.log(JSON.stringify(result));
});
```

---

## 4. 상태 코드

### 4.1 Status ID 매핑

| ID | Description | 의미 |
|----|-------------|------|
| 1 | In Queue | 대기 중 |
| 2 | Processing | 처리 중 |
| 3 | Accepted | 정답 |
| 4 | Wrong Answer | 오답 |
| 5 | Time Limit Exceeded | 시간 초과 |
| 6 | Compilation Error | 컴파일 에러 |
| 7 | Runtime Error (SIGSEGV) | 세그멘테이션 폴트 |
| 8 | Runtime Error (SIGXFSZ) | 파일 크기 초과 |
| 9 | Runtime Error (SIGFPE) | 부동소수점 에러 |
| 10 | Runtime Error (SIGABRT) | 중단 |
| 11 | Runtime Error (NZEC) | 비정상 종료 |
| 12 | Runtime Error (Other) | 기타 런타임 에러 |
| 13 | Internal Error | 내부 에러 |
| 14 | Exec Format Error | 실행 형식 에러 |

### 4.2 상태 분류

```java
public enum SubmissionStatus {
    // 대기/처리 중
    IN_QUEUE(1),
    PROCESSING(2),

    // 성공
    ACCEPTED(3),

    // 실패 (오답)
    WRONG_ANSWER(4),

    // 제한 초과
    TIME_LIMIT_EXCEEDED(5),
    MEMORY_LIMIT_EXCEEDED(/* 없음, memory 필드로 판단 */),

    // 에러
    COMPILATION_ERROR(6),
    RUNTIME_ERROR_SIGSEGV(7),
    RUNTIME_ERROR_SIGXFSZ(8),
    RUNTIME_ERROR_SIGFPE(9),
    RUNTIME_ERROR_SIGABRT(10),
    RUNTIME_ERROR_NZEC(11),
    RUNTIME_ERROR_OTHER(12),
    INTERNAL_ERROR(13),
    EXEC_FORMAT_ERROR(14);
}
```

---

## 5. Spring Boot 연동

### 5.1 의존성 추가

```gradle
// build.gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-webflux'  // WebClient
}
```

### 5.2 설정 클래스

```java
@Configuration
@ConfigurationProperties(prefix = "judge0")
@Getter @Setter
public class Judge0Config {
    private String apiUrl = "http://localhost:2358";
    private int maxRetries = 3;
    private int retryDelayMs = 1000;
    private int timeoutSeconds = 30;
}

@Configuration
public class WebClientConfig {

    @Bean
    public WebClient judge0WebClient(Judge0Config config) {
        return WebClient.builder()
                .baseUrl(config.getApiUrl())
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .codecs(configurer -> configurer
                        .defaultCodecs()
                        .maxInMemorySize(10 * 1024 * 1024))  // 10MB
                .build();
    }
}
```

### 5.3 Judge0 클라이언트

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class Judge0Client {

    private final WebClient judge0WebClient;
    private final Judge0Config config;

    /**
     * 코드 실행 요청 (비동기)
     */
    public Mono<String> submit(Judge0SubmissionRequest request) {
        return judge0WebClient.post()
                .uri("/submissions")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(Judge0SubmissionResponse.class)
                .map(Judge0SubmissionResponse::getToken)
                .timeout(Duration.ofSeconds(config.getTimeoutSeconds()))
                .doOnError(e -> log.error("Judge0 submission failed", e));
    }

    /**
     * 코드 실행 요청 (동기 - 결과 대기)
     */
    public Mono<Judge0Result> submitAndWait(Judge0SubmissionRequest request) {
        return judge0WebClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path("/submissions")
                        .queryParam("wait", "true")
                        .queryParam("fields", "stdout,stderr,status,time,memory,compile_output")
                        .build())
                .bodyValue(request)
                .retrieve()
                .bodyToMono(Judge0Result.class)
                .timeout(Duration.ofSeconds(config.getTimeoutSeconds()));
    }

    /**
     * 실행 결과 조회
     */
    public Mono<Judge0Result> getResult(String token) {
        return judge0WebClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/submissions/{token}")
                        .queryParam("fields", "stdout,stderr,status,time,memory,compile_output")
                        .build(token))
                .retrieve()
                .bodyToMono(Judge0Result.class)
                .timeout(Duration.ofSeconds(config.getTimeoutSeconds()));
    }

    /**
     * 결과 폴링 (완료될 때까지)
     */
    public Mono<Judge0Result> pollResult(String token) {
        return getResult(token)
                .flatMap(result -> {
                    if (result.isFinished()) {
                        return Mono.just(result);
                    }
                    return Mono.delay(Duration.ofMillis(config.getRetryDelayMs()))
                            .flatMap(l -> pollResult(token));
                })
                .retry(config.getMaxRetries());
    }
}
```

### 5.4 DTO 클래스

```java
@Getter @Setter
@Builder
public class Judge0SubmissionRequest {
    @JsonProperty("source_code")
    private String sourceCode;

    @JsonProperty("language_id")
    private Integer languageId;

    private String stdin;

    @JsonProperty("expected_output")
    private String expectedOutput;

    @JsonProperty("cpu_time_limit")
    private Float cpuTimeLimit;

    @JsonProperty("memory_limit")
    private Integer memoryLimit;
}

@Getter @Setter
public class Judge0Result {
    private String token;
    private String stdout;
    private String stderr;

    @JsonProperty("compile_output")
    private String compileOutput;

    private String message;
    private String time;
    private Integer memory;

    @JsonProperty("exit_code")
    private Integer exitCode;

    private Judge0Status status;

    public boolean isFinished() {
        return status != null && status.getId() >= 3;
    }

    public boolean isAccepted() {
        return status != null && status.getId() == 3;
    }
}

@Getter @Setter
public class Judge0Status {
    private Integer id;
    private String description;
}
```

---

## 6. 배치 실행

여러 테스트케이스를 한 번에 실행합니다.

### 6.1 배치 요청

**POST /submissions/batch**

```bash
curl -X POST "http://localhost:2358/submissions/batch" \
  -H "Content-Type: application/json" \
  -d '{
    "submissions": [
      {
        "source_code": "print(sum([int(x) for x in input().split()]))",
        "language_id": 71,
        "stdin": "1 2 3",
        "expected_output": "6\n"
      },
      {
        "source_code": "print(sum([int(x) for x in input().split()]))",
        "language_id": 71,
        "stdin": "10 20 30",
        "expected_output": "60\n"
      }
    ]
  }'
```

**Response:**

```json
[
  { "token": "token-1-xxx" },
  { "token": "token-2-xxx" }
]
```

### 6.2 배치 결과 조회

```bash
curl "http://localhost:2358/submissions/batch?tokens=token-1-xxx,token-2-xxx&fields=status,stdout,time,memory"
```

---

## 7. 에러 처리

### 7.1 연결 에러

```java
@Service
public class Judge0Service {

    public ExecutionResult execute(ExecutionRequest request) {
        try {
            return judge0Client.submitAndWait(toJudge0Request(request))
                    .map(this::toExecutionResult)
                    .block();
        } catch (WebClientRequestException e) {
            log.error("Judge0 connection failed", e);
            throw new Judge0UnavailableException("Code execution service unavailable");
        } catch (TimeoutException e) {
            log.error("Judge0 timeout", e);
            throw new ExecutionTimeoutException("Execution timed out");
        }
    }
}
```

### 7.2 결과 매핑

```java
private ExecutionResult toExecutionResult(Judge0Result judge0Result) {
    int statusId = judge0Result.getStatus().getId();

    return ExecutionResult.builder()
            .status(mapStatus(statusId))
            .stdout(judge0Result.getStdout())
            .executionTime(parseTime(judge0Result.getTime()))
            .memoryUsed(judge0Result.getMemory())
            .hasError(statusId >= 6)
            .errorType(statusId >= 6 ? mapErrorType(statusId) : null)
            .compileOutput(judge0Result.getCompileOutput())
            .build();
}

private String mapStatus(int statusId) {
    return switch (statusId) {
        case 3 -> "ACCEPTED";
        case 4 -> "WRONG_ANSWER";
        case 5 -> "TIME_LIMIT_EXCEEDED";
        case 6 -> "COMPILATION_ERROR";
        case 7, 8, 9, 10, 11, 12 -> "RUNTIME_ERROR";
        default -> "INTERNAL_ERROR";
    };
}
```

---

## 8. 모니터링

### 8.1 헬스체크

```java
@Component
@RequiredArgsConstructor
public class Judge0HealthIndicator implements HealthIndicator {

    private final WebClient judge0WebClient;

    @Override
    public Health health() {
        try {
            String response = judge0WebClient.get()
                    .uri("/about")
                    .retrieve()
                    .bodyToMono(String.class)
                    .block(Duration.ofSeconds(5));

            return Health.up()
                    .withDetail("judge0", "available")
                    .build();
        } catch (Exception e) {
            return Health.down()
                    .withDetail("judge0", "unavailable")
                    .withException(e)
                    .build();
        }
    }
}
```

### 8.2 메트릭 수집

```java
@Service
@RequiredArgsConstructor
public class Judge0Service {

    private final MeterRegistry meterRegistry;

    public ExecutionResult execute(ExecutionRequest request) {
        Timer.Sample sample = Timer.start(meterRegistry);

        try {
            ExecutionResult result = doExecute(request);

            // 성공 메트릭
            meterRegistry.counter("judge0.executions",
                    "status", result.getStatus(),
                    "language", request.getLanguage()
            ).increment();

            return result;
        } catch (Exception e) {
            // 실패 메트릭
            meterRegistry.counter("judge0.errors",
                    "type", e.getClass().getSimpleName()
            ).increment();
            throw e;
        } finally {
            sample.stop(meterRegistry.timer("judge0.execution.time"));
        }
    }
}
```

---

## 9. 성능 최적화

### 9.1 커넥션 풀 설정

```java
@Bean
public WebClient judge0WebClient(Judge0Config config) {
    HttpClient httpClient = HttpClient.create()
            .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 5000)
            .responseTimeout(Duration.ofSeconds(30))
            .connectionProvider(ConnectionProvider.builder("judge0")
                    .maxConnections(50)
                    .pendingAcquireTimeout(Duration.ofSeconds(10))
                    .build());

    return WebClient.builder()
            .baseUrl(config.getApiUrl())
            .clientConnector(new ReactorClientHttpConnector(httpClient))
            .build();
}
```

### 9.2 배치 처리 최적화

```java
public List<ExecutionResult> executeBatch(List<ExecutionRequest> requests) {
    // 배치 API 사용
    List<Judge0SubmissionRequest> judge0Requests = requests.stream()
            .map(this::toJudge0Request)
            .toList();

    List<String> tokens = judge0Client.submitBatch(judge0Requests).block();

    // 병렬로 결과 조회
    return Flux.fromIterable(tokens)
            .flatMap(token -> judge0Client.pollResult(token))
            .map(this::toExecutionResult)
            .collectList()
            .block();
}
```
