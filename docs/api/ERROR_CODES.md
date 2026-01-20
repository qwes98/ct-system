# Error Codes

API 에러 코드 및 응답 형식을 정의합니다.

## 1. 에러 응답 형식

### 기본 구조

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": { ... }  // 선택적 추가 정보
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### 필드 설명

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| success | boolean | Y | 항상 `false` |
| error.code | string | Y | 에러 식별 코드 (UPPER_SNAKE_CASE) |
| error.message | string | Y | 사용자 친화적 에러 메시지 |
| error.details | object | N | 추가 상세 정보 |
| timestamp | string | Y | ISO 8601 형식 타임스탬프 |

---

## 2. HTTP 상태 코드

| HTTP Status | 용도 |
|-------------|------|
| 400 Bad Request | 잘못된 요청 (검증 실패, 잘못된 파라미터) |
| 401 Unauthorized | 인증 필요 (게스트 토큰 누락/만료) |
| 403 Forbidden | 권한 없음 |
| 404 Not Found | 리소스 없음 |
| 409 Conflict | 충돌 (중복 요청 등) |
| 422 Unprocessable Entity | 처리 불가 (비즈니스 로직 에러) |
| 429 Too Many Requests | 요청 제한 초과 |
| 500 Internal Server Error | 서버 내부 오류 |
| 502 Bad Gateway | 외부 서비스 연결 실패 (Judge0 등) |
| 503 Service Unavailable | 서비스 일시 불가 |

---

## 3. 에러 코드 목록

### 3.1 공통 에러 (COMMON)

| 코드 | HTTP | 설명 | 예시 메시지 |
|------|------|------|-------------|
| `INVALID_REQUEST` | 400 | 요청 형식 오류 | "Invalid request format" |
| `VALIDATION_ERROR` | 400 | 입력값 검증 실패 | "Validation failed" |
| `MISSING_PARAMETER` | 400 | 필수 파라미터 누락 | "Required parameter 'language' is missing" |
| `INVALID_PARAMETER` | 400 | 파라미터 값 오류 | "Invalid value for parameter 'language'" |
| `RESOURCE_NOT_FOUND` | 404 | 리소스 없음 | "Requested resource not found" |
| `METHOD_NOT_ALLOWED` | 405 | 허용되지 않은 HTTP 메서드 | "Method 'PUT' not allowed" |
| `INTERNAL_ERROR` | 500 | 서버 내부 오류 | "An unexpected error occurred" |
| `SERVICE_UNAVAILABLE` | 503 | 서비스 불가 | "Service temporarily unavailable" |

**예시:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "fields": [
        {
          "field": "code",
          "message": "Code cannot be empty"
        },
        {
          "field": "language",
          "message": "Language must be one of: PYTHON, JAVA, CPP, JAVASCRIPT"
        }
      ]
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### 3.2 문제 관련 에러 (PROBLEM)

| 코드 | HTTP | 설명 | 예시 메시지 |
|------|------|------|-------------|
| `PROBLEM_NOT_FOUND` | 404 | 문제 없음 | "Problem with id 999 not found" |
| `TEMPLATE_NOT_FOUND` | 404 | 템플릿 없음 | "Template for language 'PYTHON' not found" |
| `LANGUAGE_NOT_SUPPORTED` | 400 | 지원하지 않는 언어 | "Language 'RUBY' is not supported for this problem" |

**예시:**
```json
{
  "success": false,
  "error": {
    "code": "PROBLEM_NOT_FOUND",
    "message": "Problem with id 999 not found"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### 3.3 실행 관련 에러 (EXECUTION)

| 코드 | HTTP | 설명 | 예시 메시지 |
|------|------|------|-------------|
| `CODE_TOO_LARGE` | 400 | 코드 크기 초과 | "Code size exceeds maximum limit of 64KB" |
| `EXECUTION_TIMEOUT` | 408 | 실행 타임아웃 | "Execution timed out" |
| `EXECUTION_FAILED` | 500 | 실행 실패 | "Code execution failed" |
| `JUDGE0_UNAVAILABLE` | 502 | Judge0 연결 실패 | "Code execution service unavailable" |
| `JUDGE0_ERROR` | 502 | Judge0 에러 | "Code execution service returned an error" |

**예시:**
```json
{
  "success": false,
  "error": {
    "code": "CODE_TOO_LARGE",
    "message": "Code size exceeds maximum limit of 64KB",
    "details": {
      "maxSize": 65536,
      "actualSize": 72000
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### 3.4 제출 관련 에러 (SUBMISSION)

| 코드 | HTTP | 설명 | 예시 메시지 |
|------|------|------|-------------|
| `SUBMISSION_NOT_FOUND` | 404 | 제출 기록 없음 | "Submission 'sub_abc123' not found" |
| `SUBMISSION_IN_PROGRESS` | 409 | 이미 진행 중인 제출 있음 | "Another submission is already in progress" |
| `QUEUE_FULL` | 503 | 대기열 가득 참 | "Submission queue is full. Please try again later" |

**예시:**
```json
{
  "success": false,
  "error": {
    "code": "SUBMISSION_IN_PROGRESS",
    "message": "Another submission is already in progress",
    "details": {
      "existingSubmissionId": "sub_xyz789",
      "status": "RUNNING"
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### 3.5 인증/세션 에러 (AUTH)

| 코드 | HTTP | 설명 | 예시 메시지 |
|------|------|------|-------------|
| `GUEST_TOKEN_REQUIRED` | 401 | 게스트 토큰 필요 | "Guest token is required" |
| `GUEST_TOKEN_INVALID` | 401 | 게스트 토큰 무효 | "Invalid guest token" |
| `GUEST_TOKEN_EXPIRED` | 401 | 게스트 토큰 만료 | "Guest token has expired" |

**예시:**
```json
{
  "success": false,
  "error": {
    "code": "GUEST_TOKEN_EXPIRED",
    "message": "Guest token has expired",
    "details": {
      "expiredAt": "2024-01-14T10:30:00Z"
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### 3.6 Rate Limit 에러 (RATE_LIMIT)

| 코드 | HTTP | 설명 | 예시 메시지 |
|------|------|------|-------------|
| `RATE_LIMIT_EXCEEDED` | 429 | 요청 제한 초과 | "Too many requests. Please try again later" |

**예시:**
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later",
    "details": {
      "limit": 30,
      "window": "1 minute",
      "retryAfter": 45
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**관련 헤더:**
```
Retry-After: 45
X-RateLimit-Limit: 30
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1705315800
```

---

## 4. 에러 코드 네이밍 규칙

### 4.1 형식

```
{DOMAIN}_{SPECIFIC_ERROR}
```

### 4.2 Domain 접두사

| Domain | 설명 |
|--------|------|
| (없음) | 공통 에러 |
| `PROBLEM_` | 문제 관련 |
| `SUBMISSION_` | 제출 관련 |
| `EXECUTION_` | 실행 관련 |
| `GUEST_TOKEN_` | 게스트 토큰 관련 |
| `RATE_LIMIT_` | Rate limit 관련 |
| `JUDGE0_` | Judge0 관련 |

### 4.3 규칙

- 모두 대문자 (UPPER_SNAKE_CASE)
- 명확하고 구체적인 이름 사용
- 과거형보다 상태/결과 형태 선호 (`NOT_FOUND` > `WAS_NOT_FOUND`)

---

## 5. 클라이언트 에러 처리 가이드

### 5.1 재시도 가능 에러

| 코드 | 재시도 전략 |
|------|-------------|
| `RATE_LIMIT_EXCEEDED` | `Retry-After` 헤더 값 후 재시도 |
| `JUDGE0_UNAVAILABLE` | 지수 백오프로 최대 3회 재시도 |
| `QUEUE_FULL` | 5-10초 후 재시도 |
| `SERVICE_UNAVAILABLE` | 지수 백오프로 재시도 |

### 5.2 재시도 불가 에러

| 코드 | 처리 방법 |
|------|-----------|
| `VALIDATION_ERROR` | 사용자에게 입력 수정 요청 |
| `PROBLEM_NOT_FOUND` | 에러 표시 후 목록으로 이동 |
| `CODE_TOO_LARGE` | 코드 크기 축소 안내 |
| `GUEST_TOKEN_EXPIRED` | 새 토큰 발급 후 재요청 |

### 5.3 지수 백오프 예시

```javascript
async function retryWithBackoff(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;

      const retryAfter = error.response?.headers?.['retry-after'];
      const delay = retryAfter
        ? parseInt(retryAfter) * 1000
        : Math.pow(2, i) * 1000 + Math.random() * 1000;

      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

---

## 6. 에러 로깅

### 6.1 서버 로그 형식

```json
{
  "timestamp": "2024-01-15T10:30:00.123Z",
  "level": "ERROR",
  "requestId": "req_abc123",
  "errorCode": "JUDGE0_UNAVAILABLE",
  "message": "Code execution service unavailable",
  "path": "/api/v1/run",
  "method": "POST",
  "clientIp": "192.168.1.100",
  "duration": 5032,
  "stackTrace": "...",
  "context": {
    "problemId": 1,
    "language": "PYTHON"
  }
}
```

### 6.2 민감 정보 제외

로그에 포함하면 안 되는 정보:
- 사용자 코드 전문
- 게스트 토큰 전체
- 테스트케이스 입/출력값

---

## 7. 에러 코드 추가 절차

1. 이 문서에 에러 코드 추가
2. 백엔드 `ErrorCode` enum에 추가
3. 프론트엔드 에러 핸들링 코드 업데이트
4. API 문서 업데이트
5. PR 리뷰 및 머지
