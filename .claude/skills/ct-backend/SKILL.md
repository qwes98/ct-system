---
name: ct-backend
description: 코딩테스트 연습 플랫폼(ct-system) 백엔드 개발. Spring Boot 3.x + SQLite + Judge0 기반 REST API 구현시 사용.
triggers:
  - ct-system backend
  - 문제 API
  - 제출 API
  - Judge0 연동
  - 실행 엔진
  - 게스트 토큰
  - submission queue
role: specialist
scope: implementation
output-format: code
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# CT-Backend: 코딩테스트 플랫폼 백엔드 개발 스킬

## 프로젝트 컨텍스트

**비용 목표**: 월 1만원 이하 (~$7-8 USD)
**아키텍처**: `Vercel (Frontend) → Single VM (Spring Boot + Judge0 + SQLite)`

## 핵심 기술 스택

| 컴포넌트 | 기술 | 비고 |
|----------|------|------|
| Framework | Spring Boot 3.x (Java 17+) | Gradle 빌드 |
| Database | SQLite (WAL mode) | MVP 전용, PostgreSQL 마이그레이션 경로 |
| Queue | In-Memory BlockingQueue | Redis 없이 @Async 활용 |
| Code Execution | Judge0 (self-hosted) | Docker 기반 샌드박스 |

## API 구조

**Base URL**: `/api/v1`

```java
// 공통 응답 wrapper
record ApiResponse<T>(boolean success, T data, String timestamp) {}
record ErrorResponse(boolean success, ErrorDetail error, String timestamp) {}
```

### 핵심 엔드포인트

| Method | Endpoint | 설명 | Rate Limit |
|--------|----------|------|------------|
| GET | `/problems` | 문제 목록 (페이지네이션) | - |
| GET | `/problems/{id}` | 문제 상세 | - |
| GET | `/problems/{id}/template` | 언어별 템플릿 | - |
| POST | `/run` | 샘플 테스트 실행 (동기) | 30/min/IP |
| POST | `/submit` | 전체 테스트 제출 (비동기, 202) | 10/min/IP |
| GET | `/submissions/{id}` | 제출 상태 조회 | - |
| GET | `/submissions` | 게스트 제출 이력 | - |

## 제출 상태 머신

```
QUEUED → RUNNING → DONE
```

- **Run**: 동기 처리, 최대 10 concurrent
- **Submit**: 비동기 (202 Accepted), 클라이언트 폴링, 최대 5 concurrent workers

## 패키지 구조

```
com.ctsystem/
  ├── config/           # 설정 클래스
  ├── controller/       # REST 컨트롤러
  ├── service/          # 비즈니스 로직
  ├── repository/       # 데이터 접근
  ├── domain/           # JPA 엔티티
  ├── dto/              # Request/Response DTO
  ├── exception/        # 커스텀 예외
  └── util/             # 유틸리티
```

## Judge0 연동 핵심

**Language IDs**: Python(71), Java(62), C++(54), JavaScript(63)

**리소스 제한**:
- CPU: 5초
- Memory: 256MB (기본)
- Network: 완전 차단 (ENABLE_NETWORK=false)

**상태 매핑**:
```java
// Judge0 status_id → 내부 상태
3  → ACCEPTED
4  → WRONG_ANSWER
5  → TIME_LIMIT_EXCEEDED
6  → COMPILATION_ERROR
7-12 → RUNTIME_ERROR
```

## 코드 패턴

### Controller
```java
@RestController
@RequestMapping("/api/v1/problems")
@RequiredArgsConstructor
public class ProblemController {
    private final ProblemService problemService;

    @GetMapping("/{id}")
    public ApiResponse<ProblemDetailResponse> getProblem(@PathVariable Long id) {
        return ApiResponse.success(problemService.findById(id));
    }
}
```

### Service
```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProblemService {
    private final ProblemRepository problemRepository;

    public ProblemDetailResponse findById(Long id) {
        return problemRepository.findById(id)
            .map(ProblemDetailResponse::from)
            .orElseThrow(() -> new ProblemNotFoundException(id));
    }
}
```

### 비동기 Submit 처리
```java
@Service
@RequiredArgsConstructor
public class SubmitService {
    private final BlockingQueue<SubmitTask> queue = new LinkedBlockingQueue<>();

    @Async
    public void processSubmission(SubmitTask task) {
        // Judge0 호출 → 결과 저장 → 상태 업데이트
    }
}
```

## MUST DO

1. **입력 검증**: 코드 64KB, 입력 10KB 제한
2. **Rate Limiting**: IP 기반 단순 구현 (분산 캐시 불필요)
3. **에러 응답**: 표준 ErrorResponse 형식 준수
4. **트랜잭션**: 조회는 `@Transactional(readOnly = true)`
5. **DI**: `@RequiredArgsConstructor` + final 필드

## MUST NOT

1. **stderr/compile_output 노출 금지**: 보안상 사용자에게 상세 로그 비공개
2. **동기 Submit 금지**: 반드시 202 + 폴링 패턴 사용
3. **Redis/외부 큐 도입 금지**: MVP는 인메모리 큐만

## 관련 문서

| 문서 | 경로 | 용도 |
|------|------|------|
| PRD | `docs/PRD.md` | 제품 요구사항 |
| API 명세 | `docs/api/API_SPECIFICATION.md` | 상세 API 스펙 |
| 에러 코드 | `docs/api/ERROR_CODES.md` | 에러 처리 |
| 시스템 아키텍처 | `docs/architecture/SYSTEM_ARCHITECTURE.md` | 전체 구조 |
| DB 스키마 | `docs/database/DATA_DICTIONARY.md` | 테이블 정의 |
| Judge0 연동 | `docs/judge0/INTEGRATION_GUIDE.md` | 실행 엔진 |
| 코딩 컨벤션 | `docs/development/CODING_CONVENTION.md` | 코드 스타일 |

## 관련 스킬

| 스킬 | 용도 |
|------|------|
| `spring-boot-engineer` | Spring Boot 3.x 프레임워크 패턴 |
| `api-designer` | REST API 설계 원칙 |
| `java-architect` | Java 엔터프라이즈 아키텍처 |
| `database-optimizer` | SQLite 최적화 및 쿼리 튜닝 |
| `ct-frontend` | 프론트엔드 연동 컨텍스트 |
