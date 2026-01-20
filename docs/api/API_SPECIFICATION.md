# API Specification

REST API 명세서입니다. OpenAPI 3.0 스타일로 작성되었습니다.

## 1. 개요

### Base URL

| 환경 | URL |
|------|-----|
| Local | `http://localhost:8080/api/v1` |
| Development | `https://dev-api.ct-system.com/api/v1` |
| Production | `https://api.ct-system.com/api/v1` |

### 공통 헤더

**Request Headers:**
```
Content-Type: application/json
X-Guest-Token: {guest-token}  # 게스트 식별용 (선택)
```

**Response Headers:**
```
Content-Type: application/json
X-Request-Id: {uuid}  # 요청 추적용
```

### 공통 응답 형식

**성공 응답:**
```json
{
  "success": true,
  "data": { ... },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**에러 응답:**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## 2. 문제 API (Problems)

### 2.1 문제 목록 조회

문제 리스트를 페이지네이션하여 조회합니다.

```
GET /problems
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| page | integer | N | 0 | 페이지 번호 (0부터 시작) |
| size | integer | N | 20 | 페이지 크기 (max: 100) |
| difficulty | string | N | - | 난이도 필터 (EASY, MEDIUM, HARD) |
| category | string | N | - | 카테고리 필터 |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "title": "Two Sum",
        "difficulty": "EASY",
        "category": "Array",
        "acceptanceRate": 45.2,
        "submissionCount": 1234
      },
      {
        "id": 2,
        "title": "Add Two Numbers",
        "difficulty": "MEDIUM",
        "category": "Linked List",
        "acceptanceRate": 38.7,
        "submissionCount": 987
      }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 150,
    "totalPages": 8
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### 2.2 문제 상세 조회

특정 문제의 상세 정보를 조회합니다.

```
GET /problems/{problemId}
```

**Path Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| problemId | integer | Y | 문제 ID |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Two Sum",
    "difficulty": "EASY",
    "category": "Array",
    "description": "Given an array of integers nums and an integer target...",
    "constraints": [
      "2 <= nums.length <= 10^4",
      "-10^9 <= nums[i] <= 10^9",
      "-10^9 <= target <= 10^9"
    ],
    "examples": [
      {
        "input": "nums = [2,7,11,15], target = 9",
        "output": "[0,1]",
        "explanation": "Because nums[0] + nums[1] == 9, we return [0, 1]."
      },
      {
        "input": "nums = [3,2,4], target = 6",
        "output": "[1,2]",
        "explanation": null
      }
    ],
    "timeLimit": 2000,
    "memoryLimit": 512,
    "supportedLanguages": ["PYTHON", "JAVA", "CPP", "JAVASCRIPT"],
    "sampleTestCount": 2,
    "hiddenTestCount": 15
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Response (404 Not Found):**
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

### 2.3 언어별 템플릿 조회

특정 문제의 언어별 코드 템플릿을 조회합니다.

```
GET /problems/{problemId}/template
```

**Path Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| problemId | integer | Y | 문제 ID |

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| language | string | Y | 언어 (PYTHON, JAVA, CPP, JAVASCRIPT) |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "problemId": 1,
    "language": "PYTHON",
    "template": "from typing import List\n\nclass Solution:\n    def twoSum(self, nums: List[int], target: int) -> List[int]:\n        # Write your code here\n        pass",
    "functionSignature": "def twoSum(self, nums: List[int], target: int) -> List[int]"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## 3. 실행 API (Run / Submit)

### 3.1 Run (샘플 테스트 실행)

샘플 테스트케이스만 실행합니다. **동기 처리**로 즉시 결과를 반환합니다.

```
POST /run
```

**Request Body:**
```json
{
  "problemId": 1,
  "language": "PYTHON",
  "code": "class Solution:\n    def twoSum(self, nums, target):\n        for i in range(len(nums)):\n            for j in range(i+1, len(nums)):\n                if nums[i] + nums[j] == target:\n                    return [i, j]"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| problemId | integer | Y | 문제 ID |
| language | string | Y | 언어 (PYTHON, JAVA, CPP, JAVASCRIPT) |
| code | string | Y | 사용자 작성 코드 |

**Response (200 OK) - 성공:**
```json
{
  "success": true,
  "data": {
    "status": "ACCEPTED",
    "totalTests": 2,
    "passedTests": 2,
    "hasError": false,
    "executionTime": 45,
    "memoryUsed": 14200,
    "results": [
      {
        "testCase": 1,
        "passed": true,
        "executionTime": 20,
        "input": "nums = [2,7,11,15], target = 9",
        "expected": "[0,1]",
        "actual": "[0, 1]"
      },
      {
        "testCase": 2,
        "passed": true,
        "executionTime": 25,
        "input": "nums = [3,2,4], target = 6",
        "expected": "[1,2]",
        "actual": "[1, 2]"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Response (200 OK) - 실패 (오답):**
```json
{
  "success": true,
  "data": {
    "status": "WRONG_ANSWER",
    "totalTests": 2,
    "passedTests": 1,
    "hasError": false,
    "executionTime": 40,
    "memoryUsed": 14000,
    "results": [
      {
        "testCase": 1,
        "passed": true,
        "executionTime": 20,
        "input": "nums = [2,7,11,15], target = 9",
        "expected": "[0,1]",
        "actual": "[0, 1]"
      },
      {
        "testCase": 2,
        "passed": false,
        "executionTime": 20,
        "input": "nums = [3,2,4], target = 6",
        "expected": "[1,2]",
        "actual": "[0, 2]"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Response (200 OK) - 에러 발생:**
```json
{
  "success": true,
  "data": {
    "status": "RUNTIME_ERROR",
    "totalTests": 2,
    "passedTests": 0,
    "hasError": true,
    "errorType": "RUNTIME_ERROR",
    "results": []
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**실행 상태 (status):**

| 상태 | 설명 |
|------|------|
| ACCEPTED | 모든 샘플 테스트 통과 |
| WRONG_ANSWER | 오답 |
| RUNTIME_ERROR | 런타임 에러 |
| COMPILATION_ERROR | 컴파일 에러 |
| TIME_LIMIT_EXCEEDED | 시간 초과 |
| MEMORY_LIMIT_EXCEEDED | 메모리 초과 |

---

### 3.2 Submit (전체 테스트 제출)

전체 테스트케이스(샘플 + 숨김)를 실행합니다. **비동기 처리**로 즉시 제출 ID를 반환합니다.

```
POST /submit
```

**Request Body:**
```json
{
  "problemId": 1,
  "language": "PYTHON",
  "code": "class Solution:\n    def twoSum(self, nums, target):\n        seen = {}\n        for i, num in enumerate(nums):\n            if target - num in seen:\n                return [seen[target - num], i]\n            seen[num] = i"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| problemId | integer | Y | 문제 ID |
| language | string | Y | 언어 (PYTHON, JAVA, CPP, JAVASCRIPT) |
| code | string | Y | 사용자 작성 코드 |

**Request Headers:**
```
X-Guest-Token: {guest-token}  # 게스트 이력 연동용
```

**Response (202 Accepted):**
```json
{
  "success": true,
  "data": {
    "submissionId": "sub_abc123xyz",
    "status": "QUEUED",
    "queuePosition": 3,
    "estimatedWaitTime": 5000
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### 3.3 제출 상태 조회

제출의 현재 상태와 결과를 조회합니다.

```
GET /submissions/{submissionId}
```

**Path Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| submissionId | string | Y | 제출 ID |

**Response (200 OK) - 대기 중:**
```json
{
  "success": true,
  "data": {
    "submissionId": "sub_abc123xyz",
    "status": "QUEUED",
    "queuePosition": 2,
    "createdAt": "2024-01-15T10:30:00Z"
  },
  "timestamp": "2024-01-15T10:30:05Z"
}
```

**Response (200 OK) - 실행 중:**
```json
{
  "success": true,
  "data": {
    "submissionId": "sub_abc123xyz",
    "status": "RUNNING",
    "progress": {
      "completed": 5,
      "total": 17
    },
    "createdAt": "2024-01-15T10:30:00Z"
  },
  "timestamp": "2024-01-15T10:30:10Z"
}
```

**Response (200 OK) - 완료:**
```json
{
  "success": true,
  "data": {
    "submissionId": "sub_abc123xyz",
    "problemId": 1,
    "problemTitle": "Two Sum",
    "language": "PYTHON",
    "status": "DONE",
    "result": "ACCEPTED",
    "totalTests": 17,
    "passedTests": 17,
    "hasError": false,
    "executionTime": 156,
    "memoryUsed": 14500,
    "createdAt": "2024-01-15T10:30:00Z",
    "completedAt": "2024-01-15T10:30:08Z"
  },
  "timestamp": "2024-01-15T10:30:10Z"
}
```

**Response (200 OK) - 완료 (실패):**
```json
{
  "success": true,
  "data": {
    "submissionId": "sub_abc123xyz",
    "problemId": 1,
    "problemTitle": "Two Sum",
    "language": "PYTHON",
    "status": "DONE",
    "result": "WRONG_ANSWER",
    "totalTests": 17,
    "passedTests": 12,
    "hasError": false,
    "executionTime": 203,
    "memoryUsed": 15200,
    "createdAt": "2024-01-15T10:30:00Z",
    "completedAt": "2024-01-15T10:30:12Z"
  },
  "timestamp": "2024-01-15T10:30:15Z"
}
```

**제출 상태 (status):**

| 상태 | 설명 |
|------|------|
| QUEUED | 대기열에서 대기 중 |
| RUNNING | 테스트 실행 중 |
| DONE | 실행 완료 |

**결과 (result) - status가 DONE일 때만 존재:**

| 결과 | 설명 |
|------|------|
| ACCEPTED | 모든 테스트 통과 |
| WRONG_ANSWER | 오답 |
| RUNTIME_ERROR | 런타임 에러 |
| COMPILATION_ERROR | 컴파일 에러 |
| TIME_LIMIT_EXCEEDED | 시간 초과 |
| MEMORY_LIMIT_EXCEEDED | 메모리 초과 |

---

## 4. 제출 이력 API (Submission History)

### 4.1 제출 이력 조회

게스트 사용자의 제출 이력을 조회합니다.

```
GET /submissions
```

**Request Headers:**
```
X-Guest-Token: {guest-token}  # 필수
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| page | integer | N | 0 | 페이지 번호 |
| size | integer | N | 20 | 페이지 크기 |
| problemId | integer | N | - | 특정 문제 필터 |
| result | string | N | - | 결과 필터 (ACCEPTED, WRONG_ANSWER 등) |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "submissionId": "sub_abc123xyz",
        "problemId": 1,
        "problemTitle": "Two Sum",
        "language": "PYTHON",
        "result": "ACCEPTED",
        "passedTests": 17,
        "totalTests": 17,
        "executionTime": 156,
        "createdAt": "2024-01-15T10:30:00Z"
      },
      {
        "submissionId": "sub_def456uvw",
        "problemId": 1,
        "problemTitle": "Two Sum",
        "language": "PYTHON",
        "result": "WRONG_ANSWER",
        "passedTests": 12,
        "totalTests": 17,
        "executionTime": 203,
        "createdAt": "2024-01-15T09:15:00Z"
      }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 45,
    "totalPages": 3
  },
  "timestamp": "2024-01-15T11:00:00Z"
}
```

---

## 5. 게스트 세션 API

### 5.1 게스트 토큰 발급

새로운 게스트 토큰을 발급합니다.

```
POST /guest/token
```

**Request Body:**
```json
{
  "deviceFingerprint": "abc123xyz..."
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| deviceFingerprint | string | N | 디바이스 핑거프린트 (있으면 기존 토큰 반환) |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "guestToken": "gt_xyz789abc...",
    "expiresAt": "2024-02-15T10:30:00Z",
    "isNewToken": true
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## 6. 헬스체크 API

### 6.1 서비스 상태 확인

```
GET /health
```

**Response (200 OK):**
```json
{
  "status": "UP",
  "components": {
    "db": { "status": "UP" },
    "redis": { "status": "UP" },
    "judge0": { "status": "UP" }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## 7. Rate Limiting

### 제한 정책

| 엔드포인트 | 제한 | 기준 |
|------------|------|------|
| `POST /run` | 30 req/min | IP |
| `POST /submit` | 10 req/min | IP + Guest Token |
| `GET /problems/*` | 100 req/min | IP |
| `GET /submissions/*` | 60 req/min | IP |

### Rate Limit 헤더

```
X-RateLimit-Limit: 30
X-RateLimit-Remaining: 25
X-RateLimit-Reset: 1705315800
```

### Rate Limit 초과 응답 (429 Too Many Requests)

```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "retryAfter": 45
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## 8. 입력 제한

| 항목 | 제한 |
|------|------|
| 코드 길이 | 최대 65,536 bytes (64KB) |
| 요청 본문 | 최대 1MB |
| 문자열 필드 | UTF-8 인코딩 |

---

## 9. API 버전 관리

- 현재 버전: `v1`
- 버전은 URL path에 포함: `/api/v1/...`
- Breaking change 시 새 버전 추가 (`v2`)
- 이전 버전은 최소 6개월 유지
