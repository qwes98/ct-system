# Entity Relationship Diagram (ERD)

데이터베이스 스키마 및 엔티티 관계를 정의합니다.

## 1. ERD 다이어그램

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ┌──────────────────┐          ┌──────────────────┐                        │
│  │     problems     │          │    categories    │                        │
│  ├──────────────────┤          ├──────────────────┤                        │
│  │ PK id            │          │ PK id            │                        │
│  │ FK category_id   │─────────▶│    name          │                        │
│  │    title         │          │    description   │                        │
│  │    description   │          │    created_at    │                        │
│  │    difficulty    │          └──────────────────┘                        │
│  │    constraints   │                                                      │
│  │    time_limit    │                                                      │
│  │    memory_limit  │                                                      │
│  │    created_at    │                                                      │
│  │    updated_at    │                                                      │
│  └────────┬─────────┘                                                      │
│           │                                                                 │
│           │ 1:N                                                             │
│           ▼                                                                 │
│  ┌──────────────────┐          ┌──────────────────┐                        │
│  │   test_cases     │          │    templates     │                        │
│  ├──────────────────┤          ├──────────────────┤                        │
│  │ PK id            │          │ PK id            │                        │
│  │ FK problem_id    │◀─────────│ FK problem_id    │                        │
│  │    input         │          │    language      │                        │
│  │    expected      │          │    code          │                        │
│  │    is_sample     │          │    signature     │                        │
│  │    order_num     │          │    created_at    │                        │
│  │    created_at    │          └──────────────────┘                        │
│  └──────────────────┘                                                      │
│                                                                             │
│           │                                                                 │
│           │ (참조용 - FK 아님)                                               │
│           ▼                                                                 │
│  ┌──────────────────┐          ┌──────────────────┐                        │
│  │   submissions    │          │  guest_sessions  │                        │
│  ├──────────────────┤          ├──────────────────┤                        │
│  │ PK id            │          │ PK id            │                        │
│  │    problem_id    │          │    token         │◀───────────────┐       │
│  │ FK guest_token   │─────────▶│    fingerprint   │                │       │
│  │    language      │          │    created_at    │                │       │
│  │    code          │          │    expires_at    │                │       │
│  │    status        │          │    last_used_at  │                │       │
│  │    result        │          └──────────────────┘                │       │
│  │    passed_tests  │                                              │       │
│  │    total_tests   │                                              │       │
│  │    exec_time     │          ┌──────────────────┐                │       │
│  │    memory_used   │          │ submission_queue │                │       │
│  │    has_error     │          ├──────────────────┤                │       │
│  │    error_type    │          │ PK id            │                │       │
│  │    created_at    │          │ FK submission_id │────────────────┘       │
│  │    completed_at  │          │    priority      │                        │
│  └──────────────────┘          │    created_at    │                        │
│                                │    started_at    │                        │
│                                └──────────────────┘                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 테이블 정의

### 2.1 problems (문제)

문제 정보를 저장합니다.

```sql
CREATE TABLE problems (
    id              BIGSERIAL PRIMARY KEY,
    category_id     BIGINT REFERENCES categories(id),
    title           VARCHAR(255) NOT NULL,
    description     TEXT NOT NULL,
    difficulty      VARCHAR(20) NOT NULL,  -- EASY, MEDIUM, HARD
    constraints     JSONB,                  -- 제약 조건 배열
    time_limit      INTEGER NOT NULL DEFAULT 2000,  -- ms
    memory_limit    INTEGER NOT NULL DEFAULT 512,   -- MB
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_problems_category ON problems(category_id);
CREATE INDEX idx_problems_difficulty ON problems(difficulty);
CREATE INDEX idx_problems_active ON problems(is_active) WHERE is_active = true;
```

---

### 2.2 categories (카테고리)

문제 카테고리를 저장합니다.

```sql
CREATE TABLE categories (
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT,
    display_order   INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- 초기 데이터
INSERT INTO categories (name, description, display_order) VALUES
    ('Array', '배열 관련 문제', 1),
    ('String', '문자열 관련 문제', 2),
    ('Linked List', '연결 리스트 관련 문제', 3),
    ('Tree', '트리 관련 문제', 4),
    ('Graph', '그래프 관련 문제', 5),
    ('Dynamic Programming', '동적 프로그래밍 문제', 6),
    ('Sorting', '정렬 관련 문제', 7),
    ('Searching', '탐색 관련 문제', 8),
    ('Math', '수학 관련 문제', 9),
    ('Others', '기타 문제', 99);
```

---

### 2.3 test_cases (테스트 케이스)

문제별 테스트 케이스를 저장합니다.

```sql
CREATE TABLE test_cases (
    id              BIGSERIAL PRIMARY KEY,
    problem_id      BIGINT NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    input           TEXT NOT NULL,          -- 입력값 (직렬화된 형태)
    expected_output TEXT NOT NULL,          -- 기대 출력값
    is_sample       BOOLEAN NOT NULL DEFAULT false,  -- 샘플 여부
    order_num       INTEGER NOT NULL DEFAULT 0,      -- 실행 순서
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_test_cases_problem ON test_cases(problem_id);
CREATE INDEX idx_test_cases_sample ON test_cases(problem_id, is_sample);
```

---

### 2.4 templates (코드 템플릿)

언어별 코드 템플릿을 저장합니다.

```sql
CREATE TABLE templates (
    id              BIGSERIAL PRIMARY KEY,
    problem_id      BIGINT NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    language        VARCHAR(20) NOT NULL,   -- PYTHON, JAVA, CPP, JAVASCRIPT
    code            TEXT NOT NULL,          -- 템플릿 코드
    function_signature VARCHAR(500),        -- 함수 시그니처
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    UNIQUE(problem_id, language)
);

-- 인덱스
CREATE INDEX idx_templates_problem ON templates(problem_id);
```

---

### 2.5 guest_sessions (게스트 세션)

게스트 사용자 세션을 관리합니다.

```sql
CREATE TABLE guest_sessions (
    id              BIGSERIAL PRIMARY KEY,
    token           VARCHAR(64) NOT NULL UNIQUE,  -- 게스트 토큰
    fingerprint     VARCHAR(255),                 -- 디바이스 핑거프린트
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    last_used_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_guest_sessions_token ON guest_sessions(token);
CREATE INDEX idx_guest_sessions_fingerprint ON guest_sessions(fingerprint);
CREATE INDEX idx_guest_sessions_expires ON guest_sessions(expires_at);
```

---

### 2.6 submissions (제출)

사용자 제출 기록을 저장합니다.

```sql
CREATE TABLE submissions (
    id              VARCHAR(32) PRIMARY KEY,  -- sub_xxxxx 형식
    problem_id      BIGINT NOT NULL,          -- FK 없음 (성능)
    guest_token     VARCHAR(64),              -- 게스트 토큰 (nullable)
    language        VARCHAR(20) NOT NULL,
    code            TEXT NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'QUEUED',  -- QUEUED, RUNNING, DONE
    result          VARCHAR(30),              -- ACCEPTED, WRONG_ANSWER, etc.
    passed_tests    INTEGER,
    total_tests     INTEGER,
    execution_time  INTEGER,                  -- ms
    memory_used     INTEGER,                  -- KB
    has_error       BOOLEAN DEFAULT false,
    error_type      VARCHAR(30),              -- RUNTIME_ERROR, COMPILATION_ERROR, etc.
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    completed_at    TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_status CHECK (status IN ('QUEUED', 'RUNNING', 'DONE')),
    CONSTRAINT chk_result CHECK (result IS NULL OR result IN (
        'ACCEPTED', 'WRONG_ANSWER', 'RUNTIME_ERROR',
        'COMPILATION_ERROR', 'TIME_LIMIT_EXCEEDED', 'MEMORY_LIMIT_EXCEEDED'
    ))
);

-- 인덱스
CREATE INDEX idx_submissions_guest ON submissions(guest_token);
CREATE INDEX idx_submissions_problem ON submissions(problem_id);
CREATE INDEX idx_submissions_status ON submissions(status) WHERE status != 'DONE';
CREATE INDEX idx_submissions_created ON submissions(created_at DESC);
CREATE INDEX idx_submissions_guest_problem ON submissions(guest_token, problem_id, created_at DESC);
```

---

### 2.7 submission_queue (제출 큐)

Submit 비동기 처리를 위한 큐 테이블입니다. (Redis 대안 또는 백업용)

```sql
CREATE TABLE submission_queue (
    id              BIGSERIAL PRIMARY KEY,
    submission_id   VARCHAR(32) NOT NULL REFERENCES submissions(id),
    priority        INTEGER NOT NULL DEFAULT 0,  -- 높을수록 우선
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    started_at      TIMESTAMP WITH TIME ZONE,    -- 처리 시작 시간
    worker_id       VARCHAR(50)                  -- 처리 중인 워커 ID
);

-- 인덱스
CREATE INDEX idx_queue_pending ON submission_queue(priority DESC, created_at)
    WHERE started_at IS NULL;
```

---

## 3. 관계 요약

| 관계 | 카디널리티 | 설명 |
|------|------------|------|
| categories → problems | 1:N | 카테고리당 여러 문제 |
| problems → test_cases | 1:N | 문제당 여러 테스트케이스 |
| problems → templates | 1:N | 문제당 언어별 템플릿 |
| guest_sessions → submissions | 1:N | 게스트당 여러 제출 |
| submissions → submission_queue | 1:1 | 대기 중인 제출 |

---

## 4. ENUM 타입

### 4.1 difficulty

```sql
CREATE TYPE difficulty_level AS ENUM ('EASY', 'MEDIUM', 'HARD');
```

### 4.2 language

```sql
CREATE TYPE programming_language AS ENUM ('PYTHON', 'JAVA', 'CPP', 'JAVASCRIPT');
```

### 4.3 submission_status

```sql
CREATE TYPE submission_status AS ENUM ('QUEUED', 'RUNNING', 'DONE');
```

### 4.4 execution_result

```sql
CREATE TYPE execution_result AS ENUM (
    'ACCEPTED',
    'WRONG_ANSWER',
    'RUNTIME_ERROR',
    'COMPILATION_ERROR',
    'TIME_LIMIT_EXCEEDED',
    'MEMORY_LIMIT_EXCEEDED'
);
```

---

## 5. JSONB 스키마

### 5.1 problems.constraints

```json
[
  "2 <= nums.length <= 10^4",
  "-10^9 <= nums[i] <= 10^9",
  "-10^9 <= target <= 10^9"
]
```

---

## 6. 마이그레이션 전략

### 6.1 Flyway 네이밍 규칙

```
V{version}__{description}.sql

예:
V1__create_initial_tables.sql
V2__add_categories_table.sql
V3__add_submission_index.sql
```

### 6.2 마이그레이션 순서

1. `V1__create_categories.sql`
2. `V2__create_problems.sql`
3. `V3__create_test_cases.sql`
4. `V4__create_templates.sql`
5. `V5__create_guest_sessions.sql`
6. `V6__create_submissions.sql`
7. `V7__create_submission_queue.sql`
8. `V8__seed_initial_data.sql`

---

## 7. 성능 고려사항

### 7.1 인덱스 전략

| 테이블 | 인덱스 | 용도 |
|--------|--------|------|
| problems | category_id, difficulty | 필터링 |
| test_cases | problem_id, is_sample | 테스트케이스 조회 |
| submissions | guest_token, created_at DESC | 이력 조회 |
| submissions | status (부분 인덱스) | 대기 중 제출 조회 |

### 7.2 파티셔닝 (향후)

`submissions` 테이블이 커지면 월별 파티셔닝 고려:

```sql
CREATE TABLE submissions (
    ...
) PARTITION BY RANGE (created_at);

CREATE TABLE submissions_2024_01 PARTITION OF submissions
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

### 7.3 아카이빙

- 30일 이상 된 게스트 세션 삭제
- 90일 이상 된 제출 기록 아카이브 테이블로 이동

---

## 8. 데이터 보존 정책

| 데이터 | 보존 기간 | 삭제/아카이브 |
|--------|-----------|---------------|
| problems | 영구 | - |
| test_cases | 영구 | - |
| templates | 영구 | - |
| guest_sessions | 30일 | 자동 삭제 |
| submissions | 90일 | 아카이브 후 삭제 |
| submission_queue | 7일 | 자동 삭제 |
