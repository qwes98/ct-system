# Task Breakdown (WBS)

MVP 개발 작업 분해 구조(Work Breakdown Structure)입니다.

## 1. 작업 코드 체계

```
[M#]-[영역]-[순번]

M#: 마일스톤 번호 (M0-M6)
영역: BE(백엔드), FE(프론트엔드), INFRA(인프라), QA(품질보증)
순번: 001-999
```

**예시:** `M1-BE-001` = 마일스톤 1, 백엔드, 첫 번째 작업

---

## 2. M0: 프로젝트 셋업

### 2.1 인프라 설정

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M0-INFRA-001 | Git 저장소 생성 및 설정 | - | GitHub repo |
| M0-INFRA-002 | 브랜치 보호 규칙 설정 | 001 | Branch rules |
| M0-INFRA-003 | PR/Issue 템플릿 생성 | 001 | Templates |
| M0-INFRA-004 | docker-compose.yml 작성 | - | docker-compose.yml |
| M0-INFRA-005 | Judge0 로컬 환경 테스트 | 004 | Working Judge0 |
| M0-INFRA-006 | GitHub Actions 기본 설정 | 001 | CI workflow |

### 2.2 백엔드 초기화

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M0-BE-001 | Spring Boot 프로젝트 생성 | INFRA-001 | backend/ |
| M0-BE-002 | Gradle 빌드 설정 | 001 | build.gradle |
| M0-BE-003 | 패키지 구조 생성 | 001 | Package structure |
| M0-BE-004 | application.yml 설정 | 001 | Config files |
| M0-BE-005 | Checkstyle/Spotless 설정 | 001 | Lint config |
| M0-BE-006 | JaCoCo 테스트 커버리지 설정 | 001 | Test config |

### 2.3 프론트엔드 초기화

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M0-FE-001 | Next.js 프로젝트 생성 | INFRA-001 | frontend/ |
| M0-FE-002 | TypeScript 설정 | 001 | tsconfig.json |
| M0-FE-003 | ESLint/Prettier 설정 | 001 | Lint config |
| M0-FE-004 | Tailwind CSS 설정 | 001 | tailwind.config |
| M0-FE-005 | shadcn/ui 설치 | 001, 004 | UI components |
| M0-FE-006 | 폴더 구조 생성 | 001 | Folder structure |

---

## 3. M1: 백엔드 기반 구축

### 3.1 데이터베이스

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M1-BE-001 | Flyway 설정 | M0-BE | Flyway config |
| M1-BE-002 | categories 테이블 마이그레이션 | 001 | V1 migration |
| M1-BE-003 | problems 테이블 마이그레이션 | 002 | V2 migration |
| M1-BE-004 | test_cases 테이블 마이그레이션 | 003 | V3 migration |
| M1-BE-005 | templates 테이블 마이그레이션 | 003 | V4 migration |
| M1-BE-006 | guest_sessions 테이블 마이그레이션 | 001 | V5 migration |
| M1-BE-007 | submissions 테이블 마이그레이션 | 006 | V6 migration |
| M1-BE-008 | 초기 시드 데이터 | 002-007 | Seed data |

### 3.2 도메인 엔티티

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M1-BE-011 | BaseTimeEntity 생성 | - | BaseEntity |
| M1-BE-012 | Category 엔티티 | 011 | Category.java |
| M1-BE-013 | Problem 엔티티 | 011, 012 | Problem.java |
| M1-BE-014 | TestCase 엔티티 | 011, 013 | TestCase.java |
| M1-BE-015 | Template 엔티티 | 011, 013 | Template.java |
| M1-BE-016 | GuestSession 엔티티 | 011 | GuestSession.java |
| M1-BE-017 | Submission 엔티티 | 011, 013 | Submission.java |

### 3.3 Repository

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M1-BE-021 | CategoryRepository | 012 | Repository |
| M1-BE-022 | ProblemRepository | 013 | Repository |
| M1-BE-023 | TestCaseRepository | 014 | Repository |
| M1-BE-024 | TemplateRepository | 015 | Repository |
| M1-BE-025 | GuestSessionRepository | 016 | Repository |
| M1-BE-026 | SubmissionRepository | 017 | Repository |

### 3.4 서비스 및 API

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M1-BE-031 | 공통 응답 포맷 (ApiResponse) | - | DTO |
| M1-BE-032 | 전역 예외 핸들러 | 031 | ExceptionHandler |
| M1-BE-033 | ProblemService 구현 | 022-024 | Service |
| M1-BE-034 | ProblemController 구현 | 031-033 | Controller |
| M1-BE-035 | Problem API 테스트 | 034 | Tests |
| M1-BE-036 | GuestSessionService 구현 | 025 | Service |
| M1-BE-037 | GuestController 구현 | 031, 036 | Controller |
| M1-BE-038 | Guest API 테스트 | 037 | Tests |

---

## 4. M2: 프론트엔드 기반 구축

### 4.1 공통 컴포넌트

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M2-FE-001 | Layout 컴포넌트 | M0-FE | Layout.tsx |
| M2-FE-002 | Header 컴포넌트 | 001 | Header.tsx |
| M2-FE-003 | Footer 컴포넌트 | 001 | Footer.tsx |
| M2-FE-004 | Button 변형 추가 | M0-FE-005 | UI components |
| M2-FE-005 | Card 컴포넌트 | M0-FE-005 | Card.tsx |
| M2-FE-006 | Badge 컴포넌트 | M0-FE-005 | Badge.tsx |
| M2-FE-007 | Skeleton 로딩 컴포넌트 | M0-FE-005 | Skeleton.tsx |

### 4.2 API 클라이언트

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M2-FE-011 | Axios 인스턴스 설정 | - | api/client.ts |
| M2-FE-012 | 에러 인터셉터 | 011 | Error handling |
| M2-FE-013 | Problem API 클라이언트 | 011 | api/problems.ts |
| M2-FE-014 | Guest API 클라이언트 | 011 | api/guest.ts |
| M2-FE-015 | React Query 설정 | - | Query config |
| M2-FE-016 | useProblemList 훅 | 013, 015 | Hook |
| M2-FE-017 | useProblem 훅 | 013, 015 | Hook |

### 4.3 문제 리스트 페이지

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M2-FE-021 | ProblemCard 컴포넌트 | 005, 006 | Component |
| M2-FE-022 | ProblemList 컴포넌트 | 021 | Component |
| M2-FE-023 | DifficultyBadge 컴포넌트 | 006 | Component |
| M2-FE-024 | 문제 리스트 페이지 | 016, 022 | app/page.tsx |
| M2-FE-025 | 페이지네이션 컴포넌트 | - | Pagination.tsx |
| M2-FE-026 | 리스트 페이지 테스트 | 024 | Tests |

### 4.4 문제 상세 페이지

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M2-FE-031 | Monaco Editor 설치 | - | Package |
| M2-FE-032 | CodeEditor 컴포넌트 | 031 | CodeEditor.tsx |
| M2-FE-033 | 언어 선택기 컴포넌트 | - | LanguageSelect.tsx |
| M2-FE-034 | 문제 설명 컴포넌트 | - | ProblemDescription.tsx |
| M2-FE-035 | 예시 테스트 컴포넌트 | - | Examples.tsx |
| M2-FE-036 | 문제 상세 페이지 레이아웃 | 032-035 | Layout |
| M2-FE-037 | 문제 상세 페이지 | 017, 036 | problems/[id]/page.tsx |
| M2-FE-038 | 상세 페이지 테스트 | 037 | Tests |

---

## 5. M3: Judge0 연동

### 5.1 Judge0 설정

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M3-INFRA-001 | Judge0 docker-compose 설정 | M0-INFRA-004 | Config |
| M3-INFRA-002 | Judge0 환경변수 설정 | 001 | .env |
| M3-INFRA-003 | 네트워크 격리 설정 | 001 | Network config |
| M3-INFRA-004 | 리소스 제한 검증 | 002 | Test results |
| M3-INFRA-005 | Judge0 헬스체크 설정 | 001 | Health check |

### 5.2 백엔드 Judge0 연동

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M3-BE-001 | Judge0Config 설정 클래스 | - | Config |
| M3-BE-002 | WebClient 설정 | 001 | WebClient bean |
| M3-BE-003 | Judge0Client 구현 | 002 | Client |
| M3-BE-004 | Judge0 DTO 클래스 | - | DTOs |
| M3-BE-005 | 언어별 코드 래퍼 (Python) | - | Wrapper |
| M3-BE-006 | 언어별 코드 래퍼 (Java) | - | Wrapper |
| M3-BE-007 | 언어별 코드 래퍼 (C++) | - | Wrapper |
| M3-BE-008 | 언어별 코드 래퍼 (JavaScript) | - | Wrapper |
| M3-BE-009 | Judge0Client 테스트 | 003-008 | Tests |

### 5.3 Run API 구현

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M3-BE-011 | RunRequest DTO | - | DTO |
| M3-BE-012 | RunResponse DTO | - | DTO |
| M3-BE-013 | ExecutionService 구현 | 003-008 | Service |
| M3-BE-014 | RunService 구현 | 013 | Service |
| M3-BE-015 | RunController 구현 | 011-014 | Controller |
| M3-BE-016 | Run API 테스트 | 015 | Tests |

### 5.4 Submit API 구현

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M3-BE-021 | In-Memory 큐 설정 (BlockingQueue) | - | Config |
| M3-BE-022 | SubmitRequest DTO | - | DTO |
| M3-BE-023 | SubmitResponse DTO | - | DTO |
| M3-BE-024 | SubmitService 구현 | 013, 021 | Service |
| M3-BE-025 | SubmitController 구현 | 022-024 | Controller |
| M3-BE-026 | 제출 워커 구현 | 024 | Worker |
| M3-BE-027 | 제출 상태 조회 API | 025 | Endpoint |
| M3-BE-028 | Submit API 테스트 | 025-027 | Tests |

---

## 6. M4: 기능 통합

### 6.1 프론트엔드 실행 기능

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M4-FE-001 | Run API 클라이언트 | M3-BE-015 | api/run.ts |
| M4-FE-002 | Submit API 클라이언트 | M3-BE-025 | api/submit.ts |
| M4-FE-003 | useRun 훅 | 001 | Hook |
| M4-FE-004 | useSubmit 훅 | 002 | Hook |
| M4-FE-005 | useSubmissionPolling 훅 | 002 | Hook |
| M4-FE-006 | RunButton 컴포넌트 | 003 | Component |
| M4-FE-007 | SubmitButton 컴포넌트 | 004, 005 | Component |

### 6.2 결과 표시

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M4-FE-011 | TestResult 컴포넌트 | - | Component |
| M4-FE-012 | RunResult 컴포넌트 | 011 | Component |
| M4-FE-013 | SubmitResult 컴포넌트 | 011 | Component |
| M4-FE-014 | StatusBadge 컴포넌트 | - | Component |
| M4-FE-015 | 상태 폴링 UI | 005, 014 | UI |
| M4-FE-016 | 에러 표시 UI | - | Component |

### 6.3 제출 이력

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M4-FE-021 | Submission API 클라이언트 | M1-BE | api/submissions.ts |
| M4-FE-022 | useSubmissionHistory 훅 | 021 | Hook |
| M4-FE-023 | SubmissionCard 컴포넌트 | - | Component |
| M4-FE-024 | SubmissionList 컴포넌트 | 023 | Component |
| M4-FE-025 | 제출 이력 페이지 | 022, 024 | submissions/page.tsx |

### 6.4 통합 완성

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M4-FE-031 | 문제 상세 페이지 통합 | 001-016 | Updated page |
| M4-FE-032 | 게스트 토큰 관리 | M0-FE | Token service |
| M4-FE-033 | 전체 플로우 E2E 테스트 | 031 | E2E tests |
| M4-BE-001 | 제출 이력 API 구현 | M1-BE-026 | Endpoint |
| M4-BE-002 | Rate Limiting 구현 | - | Middleware |
| M4-BE-003 | 통합 테스트 | * | Integration tests |

---

## 7. M5: QA 및 출시 준비

### 7.1 품질 보증

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M5-QA-001 | 버그 수정 스프린트 | M4 | Bug fixes |
| M5-QA-002 | 단위 테스트 보완 | M4 | Tests |
| M5-QA-003 | 통합 테스트 보완 | M4 | Tests |
| M5-QA-004 | E2E 테스트 완성 | M4 | E2E tests |
| M5-QA-005 | 크로스 브라우저 테스트 | M4 | Test report |
| M5-QA-006 | 접근성 테스트 | M4 | A11y report |

### 7.2 성능 테스트

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M5-PERF-001 | 부하 테스트 스크립트 작성 | - | k6/Artillery scripts |
| M5-PERF-002 | Run 동시성 테스트 (10) | 001 | Test report |
| M5-PERF-003 | Submit 동시성 테스트 (5) | 001 | Test report |
| M5-PERF-004 | 응답시간 P95 측정 | 002, 003 | Metrics |
| M5-PERF-005 | 병목 지점 분석 및 개선 | 004 | Optimizations |

### 7.3 보안 점검

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M5-SEC-001 | 의존성 취약점 스캔 | - | Report |
| M5-SEC-002 | OWASP Top 10 점검 | - | Checklist |
| M5-SEC-003 | Judge0 보안 설정 검증 | - | Report |
| M5-SEC-004 | 입력 검증 테스트 | - | Test report |
| M5-SEC-005 | Rate Limiting 테스트 | - | Test report |

### 7.4 배포 준비

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M5-INFRA-001 | Oracle Cloud Free Tier / VPS 프로비저닝 | - | VM instance |
| M5-INFRA-002 | 프로덕션 환경변수 설정 | 001 | Secrets |
| M5-INFRA-003 | 모니터링 설정 (기본) | 001 | Uptime check |
| M5-INFRA-004 | 알림 설정 | 003 | Alerts |
| M5-INFRA-005 | SQLite 백업 스크립트 | 001 | Backup script |
| M5-INFRA-006 | 배포 파이프라인 완성 | 001 | CD pipeline |
| M5-INFRA-007 | 배포 리허설 | 001-006 | Rehearsal log |

---

## 8. M6: MVP 출시

### 8.1 배포

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M6-DEPLOY-001 | 데이터베이스 마이그레이션 | M5 | Migrated DB |
| M6-DEPLOY-002 | 프론트엔드 배포 | 001 | Live frontend |
| M6-DEPLOY-003 | 백엔드 배포 | 001 | Live backend |
| M6-DEPLOY-004 | Judge0 배포 | 001 | Live Judge0 |
| M6-DEPLOY-005 | DNS 설정 | 002-004 | Domain active |
| M6-DEPLOY-006 | SSL 인증서 확인 | 005 | HTTPS active |
| M6-DEPLOY-007 | 스모크 테스트 | 006 | Test report |

### 8.2 출시 후

| 코드 | 작업 | 선행 작업 | 산출물 |
|------|------|-----------|--------|
| M6-OPS-001 | 모니터링 확인 | 007 | Dashboard check |
| M6-OPS-002 | 알림 테스트 | 007 | Alert test |
| M6-OPS-003 | 롤백 절차 문서화 | 007 | Runbook |
| M6-OPS-004 | 온콜 일정 수립 | 007 | On-call schedule |

---

## 9. 작업 의존성 다이어그램

```
M0 (Setup)
├── INFRA ─────────────────────────────────────┐
│   ├── Git repo                               │
│   ├── Docker compose                         │
│   └── CI/CD                                  │
├── BE ────────────────────────────────────────┤
│   ├── Spring Boot init                       │
│   └── Gradle setup                           │
└── FE ────────────────────────────────────────┤
    ├── Next.js init                           │
    └── shadcn/ui setup                        │
                                               │
M1 (Backend) ◀─────────────────────────────────┘
├── DB Migrations
├── Entities
├── Repositories
└── Problem API
        │
        ▼
M2 (Frontend) ◀────────────────────────────────
├── Common components
├── API client
├── Problem list page
└── Problem detail page (basic)
        │
        ▼
M3 (Judge0) ◀──────────────────────────────────
├── Judge0 setup
├── Judge0 client
├── Run API
└── Submit API
        │
        ▼
M4 (Integration) ◀─────────────────────────────
├── FE-BE integration
├── Result display
├── Submission history
└── Full flow
        │
        ▼
M5 (QA) ◀──────────────────────────────────────
├── Bug fixes
├── Performance test
├── Security check
└── Deploy preparation
        │
        ▼
M6 (Launch) ◀──────────────────────────────────
├── Production deploy
├── Monitoring
└── Operations
```

---

## 10. 작업 추정 가이드

### 10.1 작업 크기 기준

| 크기 | 스토리 포인트 | 설명 |
|------|---------------|------|
| XS | 1 | 설정 변경, 간단한 수정 |
| S | 2 | 단일 컴포넌트/API |
| M | 3 | 복잡한 컴포넌트, 여러 파일 |
| L | 5 | 기능 단위, 통합 작업 |
| XL | 8 | 대규모 기능, 아키텍처 작업 |

### 10.2 마일스톤별 예상 포인트

| 마일스톤 | 예상 포인트 |
|----------|-------------|
| M0 | 20 |
| M1 | 35 |
| M2 | 40 |
| M3 | 45 |
| M4 | 35 |
| M5 | 30 |
| M6 | 15 |
| **합계** | **220** |
