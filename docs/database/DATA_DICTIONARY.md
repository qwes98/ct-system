# Data Dictionary

데이터베이스 테이블별 컬럼 정의서입니다.

## 1. problems (문제)

문제 정보를 저장하는 핵심 테이블입니다.

| 컬럼 | 타입 | Nullable | 기본값 | 설명 |
|------|------|----------|--------|------|
| id | BIGSERIAL | NO | auto | 문제 고유 식별자 (PK) |
| category_id | BIGINT | YES | NULL | 카테고리 ID (FK → categories.id) |
| title | VARCHAR(255) | NO | - | 문제 제목 |
| description | TEXT | NO | - | 문제 설명 (Markdown 지원) |
| difficulty | VARCHAR(20) | NO | - | 난이도: EASY, MEDIUM, HARD |
| constraints | JSONB | YES | NULL | 제약 조건 배열 (JSON) |
| time_limit | INTEGER | NO | 2000 | 시간 제한 (밀리초) |
| memory_limit | INTEGER | NO | 512 | 메모리 제한 (MB) |
| is_active | BOOLEAN | NO | true | 활성화 여부 |
| created_at | TIMESTAMPTZ | NO | NOW() | 생성 시각 |
| updated_at | TIMESTAMPTZ | NO | NOW() | 수정 시각 |

### 제약 조건

- **PK**: `id`
- **FK**: `category_id` → `categories(id)`
- **CHECK**: `difficulty IN ('EASY', 'MEDIUM', 'HARD')`
- **CHECK**: `time_limit > 0`
- **CHECK**: `memory_limit > 0`

### 인덱스

| 인덱스명 | 컬럼 | 타입 |
|----------|------|------|
| idx_problems_category | category_id | B-TREE |
| idx_problems_difficulty | difficulty | B-TREE |
| idx_problems_active | is_active | B-TREE (부분: WHERE is_active = true) |

### constraints 컬럼 예시

```json
[
  "2 <= nums.length <= 10^4",
  "-10^9 <= nums[i] <= 10^9",
  "Only one valid answer exists"
]
```

---

## 2. categories (카테고리)

문제 분류를 위한 카테고리 테이블입니다.

| 컬럼 | 타입 | Nullable | 기본값 | 설명 |
|------|------|----------|--------|------|
| id | BIGSERIAL | NO | auto | 카테고리 고유 식별자 (PK) |
| name | VARCHAR(100) | NO | - | 카테고리 이름 (유니크) |
| description | TEXT | YES | NULL | 카테고리 설명 |
| display_order | INTEGER | NO | 0 | 표시 순서 |
| created_at | TIMESTAMPTZ | NO | NOW() | 생성 시각 |

### 제약 조건

- **PK**: `id`
- **UNIQUE**: `name`

### 초기 데이터

| name | description | display_order |
|------|-------------|---------------|
| Array | 배열 관련 문제 | 1 |
| String | 문자열 관련 문제 | 2 |
| Linked List | 연결 리스트 관련 문제 | 3 |
| Tree | 트리 관련 문제 | 4 |
| Graph | 그래프 관련 문제 | 5 |
| Dynamic Programming | 동적 프로그래밍 문제 | 6 |
| Sorting | 정렬 관련 문제 | 7 |
| Searching | 탐색 관련 문제 | 8 |
| Math | 수학 관련 문제 | 9 |
| Others | 기타 문제 | 99 |

---

## 3. test_cases (테스트 케이스)

문제별 테스트 케이스를 저장합니다.

| 컬럼 | 타입 | Nullable | 기본값 | 설명 |
|------|------|----------|--------|------|
| id | BIGSERIAL | NO | auto | 테스트 케이스 고유 식별자 (PK) |
| problem_id | BIGINT | NO | - | 문제 ID (FK → problems.id) |
| input | TEXT | NO | - | 입력값 (직렬화된 문자열) |
| expected_output | TEXT | NO | - | 기대 출력값 |
| is_sample | BOOLEAN | NO | false | 샘플 테스트 여부 |
| order_num | INTEGER | NO | 0 | 실행 순서 |
| created_at | TIMESTAMPTZ | NO | NOW() | 생성 시각 |

### 제약 조건

- **PK**: `id`
- **FK**: `problem_id` → `problems(id)` ON DELETE CASCADE

### 인덱스

| 인덱스명 | 컬럼 | 타입 |
|----------|------|------|
| idx_test_cases_problem | problem_id | B-TREE |
| idx_test_cases_sample | (problem_id, is_sample) | B-TREE |

### input/expected_output 형식

테스트 케이스의 입출력은 JSON 직렬화된 문자열로 저장됩니다.

**예시 (Two Sum 문제):**

| input | expected_output |
|-------|-----------------|
| `{"nums": [2,7,11,15], "target": 9}` | `[0,1]` |
| `{"nums": [3,2,4], "target": 6}` | `[1,2]` |

---

## 4. templates (코드 템플릿)

언어별 코드 템플릿을 저장합니다.

| 컬럼 | 타입 | Nullable | 기본값 | 설명 |
|------|------|----------|--------|------|
| id | BIGSERIAL | NO | auto | 템플릿 고유 식별자 (PK) |
| problem_id | BIGINT | NO | - | 문제 ID (FK → problems.id) |
| language | VARCHAR(20) | NO | - | 프로그래밍 언어 |
| code | TEXT | NO | - | 템플릿 코드 |
| function_signature | VARCHAR(500) | YES | NULL | 함수 시그니처 |
| created_at | TIMESTAMPTZ | NO | NOW() | 생성 시각 |

### 제약 조건

- **PK**: `id`
- **FK**: `problem_id` → `problems(id)` ON DELETE CASCADE
- **UNIQUE**: `(problem_id, language)`
- **CHECK**: `language IN ('PYTHON', 'JAVA', 'CPP', 'JAVASCRIPT')`

### language 값

| 값 | 설명 | Judge0 Language ID |
|-----|------|-------------------|
| PYTHON | Python 3.x | 71 |
| JAVA | Java (OpenJDK) | 62 |
| CPP | C++ (GCC) | 54 |
| JAVASCRIPT | JavaScript (Node.js) | 63 |

### 템플릿 코드 예시

**Python:**
```python
from typing import List

class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        # Write your code here
        pass
```

**Java:**
```java
class Solution {
    public int[] twoSum(int[] nums, int target) {
        // Write your code here
        return new int[]{};
    }
}
```

---

## 5. guest_sessions (게스트 세션)

게스트 사용자 세션을 관리합니다.

| 컬럼 | 타입 | Nullable | 기본값 | 설명 |
|------|------|----------|--------|------|
| id | BIGSERIAL | NO | auto | 세션 고유 식별자 (PK) |
| token | VARCHAR(64) | NO | - | 게스트 토큰 (유니크) |
| fingerprint | VARCHAR(255) | YES | NULL | 디바이스 핑거프린트 |
| created_at | TIMESTAMPTZ | NO | NOW() | 생성 시각 |
| expires_at | TIMESTAMPTZ | NO | - | 만료 시각 |
| last_used_at | TIMESTAMPTZ | NO | NOW() | 마지막 사용 시각 |

### 제약 조건

- **PK**: `id`
- **UNIQUE**: `token`

### 인덱스

| 인덱스명 | 컬럼 | 타입 |
|----------|------|------|
| idx_guest_sessions_token | token | B-TREE |
| idx_guest_sessions_fingerprint | fingerprint | B-TREE |
| idx_guest_sessions_expires | expires_at | B-TREE |

### token 생성 규칙

```
gt_{random_32_chars}

예: gt_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

- 접두사: `gt_` (guest token)
- 랜덤 부분: 32자의 영숫자 (a-z, 0-9)
- 만료 기간: 생성 후 30일

---

## 6. submissions (제출)

사용자 제출 기록을 저장합니다.

| 컬럼 | 타입 | Nullable | 기본값 | 설명 |
|------|------|----------|--------|------|
| id | VARCHAR(32) | NO | - | 제출 고유 식별자 (PK) |
| problem_id | BIGINT | NO | - | 문제 ID |
| guest_token | VARCHAR(64) | YES | NULL | 게스트 토큰 |
| language | VARCHAR(20) | NO | - | 프로그래밍 언어 |
| code | TEXT | NO | - | 제출된 코드 |
| status | VARCHAR(20) | NO | QUEUED | 제출 상태 |
| result | VARCHAR(30) | YES | NULL | 실행 결과 |
| passed_tests | INTEGER | YES | NULL | 통과한 테스트 수 |
| total_tests | INTEGER | YES | NULL | 전체 테스트 수 |
| execution_time | INTEGER | YES | NULL | 실행 시간 (ms) |
| memory_used | INTEGER | YES | NULL | 메모리 사용량 (KB) |
| has_error | BOOLEAN | NO | false | 에러 발생 여부 |
| error_type | VARCHAR(30) | YES | NULL | 에러 유형 |
| created_at | TIMESTAMPTZ | NO | NOW() | 제출 시각 |
| completed_at | TIMESTAMPTZ | YES | NULL | 완료 시각 |

### 제약 조건

- **PK**: `id`
- **CHECK**: `status IN ('QUEUED', 'RUNNING', 'DONE')`
- **CHECK**: `result IS NULL OR result IN ('ACCEPTED', 'WRONG_ANSWER', 'RUNTIME_ERROR', 'COMPILATION_ERROR', 'TIME_LIMIT_EXCEEDED', 'MEMORY_LIMIT_EXCEEDED')`

### 인덱스

| 인덱스명 | 컬럼 | 타입 |
|----------|------|------|
| idx_submissions_guest | guest_token | B-TREE |
| idx_submissions_problem | problem_id | B-TREE |
| idx_submissions_status | status | B-TREE (부분: WHERE status != 'DONE') |
| idx_submissions_created | created_at DESC | B-TREE |
| idx_submissions_guest_problem | (guest_token, problem_id, created_at DESC) | B-TREE |

### id 생성 규칙

```
sub_{timestamp_base36}_{random_6_chars}

예: sub_lz5x8k9_a1b2c3
```

- 접두사: `sub_`
- 타임스탬프: Base36 인코딩된 밀리초 타임스탬프
- 랜덤 부분: 6자의 영숫자

### status 상태 전이

```
QUEUED → RUNNING → DONE
```

| status | 설명 | result 값 |
|--------|------|-----------|
| QUEUED | 대기열 대기 중 | NULL |
| RUNNING | 실행 중 | NULL |
| DONE | 완료 | NOT NULL |

### result 값

| result | 설명 | has_error |
|--------|------|-----------|
| ACCEPTED | 모든 테스트 통과 | false |
| WRONG_ANSWER | 오답 | false |
| RUNTIME_ERROR | 런타임 에러 | true |
| COMPILATION_ERROR | 컴파일 에러 | true |
| TIME_LIMIT_EXCEEDED | 시간 초과 | true |
| MEMORY_LIMIT_EXCEEDED | 메모리 초과 | true |

---

## 7. submission_queue (제출 큐)

Submit 비동기 처리를 위한 큐입니다.

| 컬럼 | 타입 | Nullable | 기본값 | 설명 |
|------|------|----------|--------|------|
| id | BIGSERIAL | NO | auto | 큐 항목 고유 식별자 (PK) |
| submission_id | VARCHAR(32) | NO | - | 제출 ID (FK → submissions.id) |
| priority | INTEGER | NO | 0 | 우선순위 (높을수록 먼저 처리) |
| created_at | TIMESTAMPTZ | NO | NOW() | 큐 등록 시각 |
| started_at | TIMESTAMPTZ | YES | NULL | 처리 시작 시각 |
| worker_id | VARCHAR(50) | YES | NULL | 처리 중인 워커 ID |

### 제약 조건

- **PK**: `id`
- **FK**: `submission_id` → `submissions(id)`

### 인덱스

| 인덱스명 | 컬럼 | 조건 |
|----------|------|------|
| idx_queue_pending | (priority DESC, created_at) | WHERE started_at IS NULL |

### priority 값

| priority | 설명 |
|----------|------|
| 0 | 일반 제출 |
| 10 | 우선 처리 (향후 유료 사용자 등) |

---

## 8. 데이터 타입 매핑

### PostgreSQL ↔ Java

| PostgreSQL | Java (JPA) |
|------------|------------|
| BIGSERIAL | Long |
| VARCHAR(n) | String |
| TEXT | String |
| INTEGER | Integer |
| BOOLEAN | Boolean |
| JSONB | String (JSON 변환) |
| TIMESTAMPTZ | Instant / ZonedDateTime |

### PostgreSQL ↔ TypeScript (Frontend)

| PostgreSQL | TypeScript |
|------------|------------|
| BIGSERIAL | number |
| VARCHAR(n) | string |
| TEXT | string |
| INTEGER | number |
| BOOLEAN | boolean |
| JSONB | object / array |
| TIMESTAMPTZ | string (ISO 8601) / Date |

---

## 9. 데이터 정합성 규칙

### 비즈니스 규칙

1. **문제 삭제 시**: 연관된 test_cases, templates 자동 삭제 (CASCADE)
2. **게스트 세션 만료 시**: 세션만 삭제, submissions는 유지
3. **제출 완료 시**: status가 DONE이면 result는 반드시 NOT NULL
4. **에러 발생 시**: has_error = true이면 error_type도 NOT NULL

### 데이터 검증 규칙

1. **code 길이**: 최대 65,536 bytes (64KB)
2. **token 형식**: `gt_`로 시작, 총 35자
3. **submission id 형식**: `sub_`로 시작
4. **시간/메모리 제한**: 양수만 허용

---

## 10. 감사(Audit) 컬럼

향후 확장을 위한 표준 감사 컬럼 패턴:

```sql
-- 모든 테이블에 적용 가능한 감사 컬럼
created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
created_by      VARCHAR(64),  -- 향후 사용자 인증 추가 시
updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_by      VARCHAR(64),  -- 향후 사용자 인증 추가 시

-- updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_problems_updated_at
    BEFORE UPDATE ON problems
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```
